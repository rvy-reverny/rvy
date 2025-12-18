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
        
        let url = std::env::var("DATABASE_URL").unwrap_or_else(|_| {
            eprintln!("❌ ERROR: DATABASE_URL environment variable is not set!");
            eprintln!("\n📝 Please set the following environment variables:");
            eprintln!("   export DATABASE_TYPE=postgres|mysql|mongodb|sqlite");
            eprintln!("   export DATABASE_URL=<your-database-connection-url>");
            eprintln!("\n💡 Examples:");
            eprintln!("   PostgreSQL: postgresql://user:password@localhost:5432/dbname");
            eprintln!("   MySQL:      mysql://user:password@localhost:3306/dbname");
            eprintln!("   MongoDB:    mongodb://localhost:27017/dbname");
            eprintln!("   SQLite:     sqlite://data.db");
            std::process::exit(1);
        });

        let db_type = match db_type.to_lowercase().as_str() {
            "postgres" => DatabaseType::Postgres,
            "mysql" => DatabaseType::Mysql,
            "mongodb" => DatabaseType::Mongodb,
            "sqlite" => DatabaseType::Sqlite,
            _ => {
                eprintln!("❌ ERROR: Unsupported database type: {}", db_type);
                eprintln!("   Supported types: postgres, mysql, mongodb, sqlite");
                std::process::exit(1);
            }
        };

        Self { db_type, url }
    }
}
