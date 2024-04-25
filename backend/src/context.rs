use redis::aio::ConnectionManager;

pub struct Context {
    pub redis_connection: ConnectionManager,
    pub auth_header: Option<String>,
    pub auth_base_url: String,
    pub auth_project_id: String,
    pub auth_server_token: String,
}
