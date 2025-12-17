use serde::{Deserialize, Serialize};
use sqlx::FromRow;

#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct {{Name}}Data {
    pub id: i64,
    pub name: String,
    pub created_at: Option<chrono::DateTime<chrono::Utc>>,
    pub updated_at: Option<chrono::DateTime<chrono::Utc>>,
    // Add your additional fields here
}

impl {{Name}}Data {
    pub fn new(id: i64, name: String) -> Self {
        Self {
            id,
            name,
            created_at: Some(chrono::Utc::now()),
            updated_at: Some(chrono::Utc::now()),
        }
    }
}
