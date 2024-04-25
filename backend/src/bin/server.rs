use backend::{context, env, graphql_api};
use base64;
use base64::Engine;
use pulsar::Error as PulsarError;
use redis;
use redis::aio::ConnectionManager;
use urlencoding;
use warp::Filter;

#[derive(Debug)]
struct PulsarErrorRejection(PulsarError);

impl warp::reject::Reject for PulsarErrorRejection {}

#[derive(Debug)]
struct LockErrorRejection(String);

impl warp::reject::Reject for LockErrorRejection {}

#[tokio::main]
async fn main() {
    let env = env::read_env().expect("Failed to read env");

    let redis_client =
        redis::Client::open(env.redis_uri.clone()).expect("Failed to create Redis client");
    let exponent_base = 2;
    let factor = 2;
    let number_of_retries = 500000;
    let redis_connection =
        ConnectionManager::new_with_backoff(redis_client, exponent_base, factor, number_of_retries)
            .await
            .expect("Failed to create Redis connection");

    let auth_client_id_encoded = urlencoding::encode(&env.auth_client_id);
    let auth_client_secret_encoded = urlencoding::encode(&env.auth_client_secret);
    let auth_server_token = base64::engine::general_purpose::STANDARD.encode(format!(
        "{auth_client_id_encoded}:{auth_client_secret_encoded}"
    ));

    let graphql_filter = juniper_warp::make_graphql_filter(
        graphql_api::schema(),
        warp::header::optional("Authorization")
            .map(move |auth_header: Option<String>| context::Context {
                redis_connection: redis_connection.clone(),
                auth_header,
                auth_base_url: env.auth_base_url.clone(),
                auth_project_id: env.auth_project_id.clone(),
                auth_server_token: auth_server_token.clone(),
            })
            .boxed(),
    );

    let graphql = warp::path("api")
        .and(warp::path("graphql"))
        .and(graphql_filter);

    let routes = graphql;

    let port = 8000;
    println!("🚀 Server started! On port {} 🚀", port);

    warp::serve(routes).run(([0, 0, 0, 0], port)).await;
}
