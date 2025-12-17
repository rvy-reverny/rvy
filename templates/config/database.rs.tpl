use serde::{Deserialize, Serialize};
use std::sync::Arc;

#[derive(Debug, Clone, Deserialize)]
pub struct DatabaseConfig {
    pub db_type: DatabaseType,
    pub url: String,
}

#[derive(Debug, Clone, Deserialize, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum DatabaseType {
    Postgres,
    Mysql,
    Mongodb,
    Sqlite,
}

impl DatabaseConfig {
    pub fn from_env() -> Self {
        let db_type = std::env::var("DATABASE_TYPE")
            .unwrap_or_else(|_| "postgres".to_string());
        let url = std::env::var("DATABASE_URL")
            .expect("DATABASE_URL must be set");

        let db_type = match db_type.to_lowercase().as_str() {
            "postgres" => DatabaseType::Postgres,
            "mysql" => DatabaseType::Mysql,
            "mongodb" => DatabaseType::Mongodb,
            "sqlite" => DatabaseType::Sqlite,
            _ => panic!("Unsupported database type: {}", db_type),
        };

        Self { db_type, url }
    }
}
