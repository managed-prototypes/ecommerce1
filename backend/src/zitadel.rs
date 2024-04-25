use std::collections::HashSet;

use crate::context::Context;
use crate::redis::keys;
use redis::{AsyncCommands, SetExpiry, SetOptions};
use reqwest;
use serde_derive::{Deserialize, Serialize};
use serde_json::Value;

/*
    if the token is invalid, then this will return:
{ "active": false }
    if the token is valid, then the following will be returned:
{
  "active": true,
  "scope": "openid profile urn:zitadel:iam:org:project:id:zitadel:aud",
  "client_id": "220047952645783557@ecommerce1",
  "token_type": "Bearer",
  "exp": 1690402698,
  "iat": 1690359498,
  "nbf": 1690359498,
  "sub": "224139274302259204", // user id
  "aud": [
    "220047952645783557@ecommerce1",
    "220048679334117381@ecommerce1",
    "224507703492411396@ecommerce1",
    "220047653491179525",
    "220043816575565827"
  ],
  "iss": "http://localhost:8091",
  "jti": "224585683237339140",
  "username": "ecommerce1-user",
  "name": "User User",
  "given_name": "User",
  "family_name": "User",
  "locale": null,
  "updated_at": 1690093419,
  "preferred_username": "ecommerce1-user"
}

    and the user with authorizations has more fields:
{
  "active": true,
  "aud": [
    "220047952645783557@ecommerce1",
    "220048679334117381@ecommerce1",
    "224594873293012996@ecommerce1",
    "220047653491179525",
    "220043816575565827"
  ],
  "client_id": "220047952645783557@ecommerce1",
  "exp": 1690436628,
  "family_name": "Admin",
  "given_name": "Admin",
  "iat": 1690393428,
  "iss": "http://localhost:8091",
  "jti": "224642608733880324",
  "locale": null,
  "name": "Admin Admin",
  "nbf": 1690393428,
  "preferred_username": "ecommerce1-admin",
  "scope": "openid profile offline_access urn:zitadel:iam:org:project:id:zitadel:aud",
  "sub": "224139347719356420",
  "token_type": "Bearer",
  "updated_at": 1690093463,
  "urn:zitadel:iam:org:project:220047653491179525:roles": {
    "moderator": {
      "220047571165380613": "ecommerce1.localhost"
    }
  },
  "urn:zitadel:iam:org:project:roles": {
    "moderator": {
      "220047571165380613": "ecommerce1.localhost"
    }
  },
  "username": "ecommerce1-admin"
}
*/
#[derive(Debug, Serialize, Deserialize)]
pub struct TokenInfo {
    pub active: bool,
    pub exp: u32,
    pub sub: String,

    pub roles: HashSet<String>,
}

fn to_object_kv_map(value: &Value) -> Result<&serde_json::Map<String, Value>, String> {
    match value {
        Value::Object(props) => Ok(props),
        _ => Err("Expected JSON object".to_string()),
    }
}

fn key_names(kv_map: &serde_json::Map<String, Value>) -> HashSet<String> {
    kv_map
        .iter()
        .map(|(role_name, _role_some_metadata)| role_name.to_string())
        .collect::<HashSet<String>>()
}

fn decode_roles_set(all_roles_value: &Value) -> Result<HashSet<String>, String> {
    to_object_kv_map(all_roles_value).map(key_names)
}

fn decode_project_roles(key: String, token_info_value: &Value) -> Result<HashSet<String>, String> {
    let kv_map = to_object_kv_map(token_info_value)?;
    match kv_map.get(&key) {
        Some(all_roles_value) => decode_roles_set(all_roles_value),
        None => Ok(HashSet::new()),
    }
}

fn decode_err(err: serde_json::Error) -> String {
    format!("TokenInfo has invalid format: {err}")
}

fn get_field<T>(field_name: &str, kv_map: &serde_json::Map<String, Value>) -> Result<T, String>
where
    T: serde::de::DeserializeOwned,
{
    kv_map
        .get(field_name)
        .ok_or(format!("Property `{field_name}` not found"))
        .and_then(|x| serde_json::from_value::<T>(x.clone()).map_err(decode_err))
}

pub fn decode_introspection_result(
    value: &Value,
    project_id: &String,
) -> Result<TokenInfo, String> {
    let kv_map = to_object_kv_map(value)?;
    let token_info = TokenInfo {
        active: get_field("active", &kv_map)?,
        exp: get_field("exp", &kv_map)?,
        sub: get_field("sub", &kv_map)?,
        roles: decode_project_roles(
            format!("urn:zitadel:iam:org:project:{project_id}:roles"),
            &value,
        )?,
    };
    Ok(token_info)
}

// Uses cache
pub async fn introspect_token(context: &Context) -> Result<TokenInfo, String> {
    let user_token = extract_user_token(context)?;

    let token_lookup_result: Result<String, redis::RedisError> = context
        .redis_connection
        .clone()
        .get(keys::user_token(&user_token))
        .await;

    match token_lookup_result {
        Ok(cached_introspection_result_string) => {
            let json_value: Value =
                serde_json::from_str(&cached_introspection_result_string).map_err(decode_err)?;
            let token_info = decode_introspection_result(&json_value, &context.auth_project_id)?;
            Ok(token_info)
        }
        Err(_) => {
            let res = introspect_and_persist_token(context, &user_token).await?;
            Ok(res)
        }
    }
}

// Doesn't use cache
pub async fn force_introspect_token(context: &Context) -> Result<TokenInfo, String> {
    let user_token = extract_user_token(context)?;
    let res = introspect_and_persist_token(context, &user_token).await?;
    Ok(res)
}

fn extract_user_token(context: &Context) -> Result<String, String> {
    let header = context
        .auth_header
        .clone()
        .ok_or("The Authorization header not found")?;
    let user_token = header
        .split_whitespace()
        .nth(1)
        .ok_or("The Authorization header has invalid format")?;
    Ok(user_token.to_string())
}

async fn introspect_and_persist_token(
    context: &Context,
    user_token: &String,
) -> Result<TokenInfo, String> {
    // TODO: Explicitly check `active == true`
    // TODO: Stop using the basic auth
    // TODO: Check `aud` field
    // TODO: decode all fields in some cases, and only the minimum in the others
    let http_client = reqwest::Client::new();
    let server_token = &context.auth_server_token;
    let base_url = &context.auth_base_url;

    let request = http_client
        .post(format!("{base_url}/oauth/v2/introspect"))
        .header("Authorization", format!("Basic {server_token}"))
        .form(&[("token", user_token)]);

    let response_something = request.send().await.map_err(|err| err.to_string())?;

    let str: String = response_something
        .text()
        .await
        .map_err(|err| err.to_string())?;
    let json_value: Value = serde_json::from_str(&str).map_err(decode_err)?;
    let token_info = decode_introspection_result(&json_value, &context.auth_project_id)?;

    // Write only if token_info is correct, but don't fail if failed to write to Redis
    let exp_timestamp_seconds: usize = token_info
        .exp
        .try_into()
        .map_err(|_| "Failed to use token expiration timestamp")?;
    // TODO: we could silently log an error if the write fails
    let _redis_write_result: Result<(), redis::RedisError> = context
        .redis_connection
        .clone()
        .set_options(
            keys::user_token(user_token),
            &str,
            SetOptions::default().with_expiration(SetExpiry::EXAT(exp_timestamp_seconds)),
        )
        .await;
    Ok(token_info)
}
