use std::sync::Arc;
use crate::config::database::{DatabaseConfig, DatabaseType};
use crate::repository::{{name}}::{{Name}}Repository;

// Import all adapters
#[cfg(feature = "postgres")]
use crate::adapter::{{name}}_postgres::Postgres{{Name}}Repository;

#[cfg(feature = "mysql")]
use crate::adapter::{{name}}_mysql::Mysql{{Name}}Repository;

#[cfg(feature = "mongodb")]
use crate::adapter::{{name}}_mongodb::Mongo{{Name}}Repository;

#[cfg(feature = "sqlite")]
use crate::adapter::{{name}}_sqlite::Sqlite{{Name}}Repository;

/// Factory function to create {{Name}}Repository based on config
pub async fn create_{{name}}_repository(
    config: &DatabaseConfig,
) -> Result<Arc<dyn {{Name}}Repository>, Box<dyn std::error::Error>> {
    match config.db_type {
        #[cfg(feature = "postgres")]
        DatabaseType::Postgres => {
            let pool = sqlx::PgPool::connect(&config.url).await?;
            Ok(Arc::new(Postgres{{Name}}Repository::new(pool)))
        }

        #[cfg(feature = "mysql")]
        DatabaseType::Mysql => {
            let pool = sqlx::MySqlPool::connect(&config.url).await?;
            Ok(Arc::new(Mysql{{Name}}Repository::new(pool)))
        }

        #[cfg(feature = "mongodb")]
        DatabaseType::Mongodb => {
            let client = mongodb::Client::with_uri_str(&config.url).await?;
            let db = client.database("mydb"); // Change database name as needed
            let collection = db.collection("{{name}}s");
            Ok(Arc::new(Mongo{{Name}}Repository::new(collection)))
        }

        #[cfg(feature = "sqlite")]
        DatabaseType::Sqlite => {
            let pool = sqlx::SqlitePool::connect(&config.url).await?;
            Ok(Arc::new(Sqlite{{Name}}Repository::new(pool)))
        }

        #[cfg(not(any(feature = "postgres", feature = "mysql", feature = "mongodb", feature = "sqlite")))]
        _ => Err("No database adapter enabled. Enable at least one feature: postgres, mysql, mongodb, or sqlite".into()),
    }
}
