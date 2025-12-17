use sqlx::{SqlitePool, FromRow};
use async_trait::async_trait;
use crate::repository::{{name}}::{{Name}}Repository;
use crate::data::{{name}}_data::{{Name}}Data;

pub struct Sqlite{{Name}}Repository {
    pool: SqlitePool,
}

impl Sqlite{{Name}}Repository {
    pub fn new(pool: SqlitePool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl {{Name}}Repository for Sqlite{{Name}}Repository {
    async fn find_by_id(&self, id: i64) -> Result<{{Name}}Data, Box<dyn std::error::Error>> {
        let row = sqlx::query_as::<_, {{Name}}Data>(
            "SELECT id, name, created_at, updated_at FROM {{name}}s WHERE id = ?"
        )
        .bind(id)
        .fetch_one(&self.pool)
        .await?;
        
        Ok(row)
    }

    async fn find_all(&self) -> Result<Vec<{{Name}}Data>, Box<dyn std::error::Error>> {
        let rows = sqlx::query_as::<_, {{Name}}Data>(
            "SELECT id, name, created_at, updated_at FROM {{name}}s"
        )
        .fetch_all(&self.pool)
        .await?;
        
        Ok(rows)
    }

    async fn save(&self, data: &{{Name}}Data) -> Result<{{Name}}Data, Box<dyn std::error::Error>> {
        let row = sqlx::query_as::<_, {{Name}}Data>(
            "INSERT INTO {{name}}s (id, name, created_at, updated_at) 
             VALUES (?, ?, ?, ?) 
             RETURNING id, name, created_at, updated_at"
        )
        .bind(data.id)
        .bind(&data.name)
        .bind(data.created_at)
        .bind(data.updated_at)
        .fetch_one(&self.pool)
        .await?;
        
        Ok(row)
    }

    async fn update(&self, id: i64, data: &{{Name}}Data) -> Result<{{Name}}Data, Box<dyn std::error::Error>> {
        let row = sqlx::query_as::<_, {{Name}}Data>(
            "UPDATE {{name}}s 
             SET name = ?, updated_at = ? 
             WHERE id = ? 
             RETURNING id, name, created_at, updated_at"
        )
        .bind(&data.name)
        .bind(chrono::Utc::now())
        .bind(id)
        .fetch_one(&self.pool)
        .await?;
        
        Ok(row)
    }

    async fn delete(&self, id: i64) -> Result<(), Box<dyn std::error::Error>> {
        sqlx::query("DELETE FROM {{name}}s WHERE id = ?")
            .bind(id)
            .execute(&self.pool)
            .await?;
        
        Ok(())
    }
}
