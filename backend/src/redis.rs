pub mod keys {
    pub fn user_token(user_token: &String) -> String {
        format!("user_token:{user_token}")
    }
}
