use sqlx::{PgPool, FromRow, postgres::PgQueryResult};
use async_trait::async_trait;
use crate::repository::{{name}}::{{Name}}Repository;
use crate::data::{{name}}_data::{{Name}}Data;
use crate::error::{Result, AppError};

pub struct Postgres{{Name}}Repository {
    pool: PgPool,
}

impl Postgres{{Name}}Repository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl {{Name}}Repository for Postgres{{Name}}Repository {
    async fn find_by_id(&self, id: i64) -> Result<{{Name}}Data> {
        let row = sqlx::query_as::<_, {{Name}}Data>(
            "SELECT * FROM {{name}}s WHERE id = $1"
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await?
        .ok_or_else(|| AppError::NotFound(format!("{{Name}} with id {} not found", id)))?;
        
        Ok(row)
    }

    async fn find_all(&self) -> Result<Vec<{{Name}}Data>> {
        let rows = sqlx::query_as::<_, {{Name}}Data>(
            "SELECT * FROM {{name}}s ORDER BY id"
        )
        .fetch_all(&self.pool)
        .await?;
        
        Ok(rows)
    }

    async fn find_all_paginated(&self, limit: i64, offset: i64) -> Result<Vec<{{Name}}Data>> {
        let rows = sqlx::query_as::<_, {{Name}}Data>(
            "SELECT * FROM {{name}}s ORDER BY id LIMIT $1 OFFSET $2"
        )
        .bind(limit)
        .bind(offset)
        .fetch_all(&self.pool)
        .await?;
        
        Ok(rows)
    }

    async fn find_by_name(&self, name: &str) -> Result<Vec<{{Name}}Data>> {
        let rows = sqlx::query_as::<_, {{Name}}Data>(
            "SELECT * FROM {{name}}s WHERE name = $1"
        )
        .bind(name)
        .fetch_all(&self.pool)
        .await?;
        
        Ok(rows)
    }

    async fn search(&self, query: &str) -> Result<Vec<{{Name}}Data>> {
        let search_pattern = format!("%{}%", query);
        let rows = sqlx::query_as::<_, {{Name}}Data>(
            "SELECT * FROM {{name}}s WHERE name ILIKE $1 ORDER BY id"
        )
        .bind(&search_pattern)
        .fetch_all(&self.pool)
        .await?;
        
        Ok(rows)
    }

    async fn count(&self) -> Result<i64> {
        let (count,): (i64,) = sqlx::query_as(
            "SELECT COUNT(*) FROM {{name}}s"
        )
        .fetch_one(&self.pool)
        .await?;
        
        Ok(count)
    }

    async fn save(&self, data: &{{Name}}Data) -> Result<{{Name}}Data> {
        let row = sqlx::query_as::<_, {{Name}}Data>(
            "INSERT INTO {{name}}s (name, created_at, updated_at) 
             VALUES ($1, COALESCE($2, NOW()), COALESCE($3, NOW())) 
             RETURNING *"
        )
        .bind(&data.name)
        .bind(data.created_at)
        .bind(data.updated_at)
        .fetch_one(&self.pool)
        .await?;
        
        Ok(row)
    }

    async fn save_many(&self, data: &[{{Name}}Data]) -> Result<Vec<{{Name}}Data>> {
        if data.is_empty() {
            return Ok(Vec::new());
        }

        let mut tx = self.pool.begin().await?;
        let mut results = Vec::with_capacity(data.len());

        for item in data {
            let row = sqlx::query_as::<_, {{Name}}Data>(
                "INSERT INTO {{name}}s (name, created_at, updated_at) 
                 VALUES ($1, COALESCE($2, NOW()), COALESCE($3, NOW())) 
                 RETURNING *"
            )
            .bind(&item.name)
            .bind(item.created_at)
            .bind(item.updated_at)
            .fetch_one(&mut *tx)
            .await?;
            
            results.push(row);
        }

        tx.commit().await?;
        Ok(results)
    }

    async fn update(&self, id: i64, data: &{{Name}}Data) -> Result<{{Name}}Data> {
        let row = sqlx::query_as::<_, {{Name}}Data>(
            "UPDATE {{name}}s 
             SET name = $1, updated_at = NOW() 
             WHERE id = $2 
             RETURNING *"
        )
        .bind(&data.name)
        .bind(id)
        .fetch_optional(&self.pool)
        .await?
        .ok_or_else(|| AppError::NotFound(format!("{{Name}} with id {} not found", id)))?;
        
        Ok(row)
    }

    async fn delete(&self, id: i64) -> Result<()> {
        let result = sqlx::query("DELETE FROM {{name}}s WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await?;
        
        if result.rows_affected() == 0 {
            return Err(AppError::NotFound(format!("{{Name}} with id {} not found", id)));
        }
        
        Ok(())
    }

    async fn delete_many(&self, ids: &[i64]) -> Result<u64> {
        if ids.is_empty() {
            return Ok(0);
        }
        
        let result = sqlx::query("DELETE FROM {{name}}s WHERE id = ANY($1)")
            .bind(ids)
            .execute(&self.pool)
            .await?;
        
        Ok(result.rows_affected())
    }
}
