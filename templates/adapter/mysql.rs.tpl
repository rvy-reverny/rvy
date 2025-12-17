use sqlx::{MySqlPool, FromRow};
use async_trait::async_trait;
use crate::repository::{{name}}::{{Name}}Repository;
use crate::data::{{name}}_data::{{Name}}Data;

pub struct Mysql{{Name}}Repository {
    pool: MySqlPool,
}

impl Mysql{{Name}}Repository {
    pub fn new(pool: MySqlPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl {{Name}}Repository for Mysql{{Name}}Repository {
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
        sqlx::query(
            "INSERT INTO {{name}}s (id, name, created_at, updated_at) 
             VALUES (?, ?, ?, ?)"
        )
        .bind(data.id)
        .bind(&data.name)
        .bind(data.created_at)
        .bind(data.updated_at)
        .execute(&self.pool)
        .await?;
        
        // Return the saved data (MySQL doesn't support RETURNING)
        self.find_by_id(data.id).await
    }

    async fn update(&self, id: i64, data: &{{Name}}Data) -> Result<{{Name}}Data, Box<dyn std::error::Error>> {
        sqlx::query(
            "UPDATE {{name}}s 
             SET name = ?, updated_at = ? 
             WHERE id = ?"
        )
        .bind(&data.name)
        .bind(chrono::Utc::now())
        .bind(id)
        .execute(&self.pool)
        .await?;
        
        self.find_by_id(id).await
    }

    async fn delete(&self, id: i64) -> Result<(), Box<dyn std::error::Error>> {
        sqlx::query("DELETE FROM {{name}}s WHERE id = ?")
            .bind(id)
            .execute(&self.pool)
            .await?;
        
        Ok(())
    }
}
