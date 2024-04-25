use std::env;

#[derive(Clone, Debug)]
pub struct Env {
    // Redis
    pub redis_uri: String,

    // Zitadel
    pub auth_base_url: String,
    pub auth_project_id: String,
    pub auth_client_id: String,
    pub auth_client_secret: String,

    // Pulsar
    pub pulsar_url: String,
}

pub fn read_env() -> Result<Env, String> {
    Ok(Env {
        // Redis
        redis_uri: env::var("BACKEND_REDIS_URI").map_err(|err| err.to_string())?,

        // Zitadel
        auth_base_url: env::var("BACKEND_AUTH_BASE_URL").map_err(|err| err.to_string())?,
        auth_project_id: env::var("BACKEND_AUTH_PROJECT_ID").map_err(|err| err.to_string())?,
        auth_client_id: env::var("BACKEND_AUTH_CLIENT_ID").map_err(|err| err.to_string())?,
        auth_client_secret: env::var("BACKEND_AUTH_CLIENT_SECRET")
            .map_err(|err| err.to_string())?,

        // Pulsar
        pulsar_url: env::var("BACKEND_PULSAR_URL").map_err(|err| err.to_string())?,
    })
}
