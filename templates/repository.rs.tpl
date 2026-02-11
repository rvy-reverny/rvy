use async_trait::async_trait;
use crate::data::{{name}}_data::{{Name}}Data;
use crate::error::Result;

#[async_trait]
pub trait {{Name}}Repository: Send + Sync {
    async fn find_by_id(&self, id: i64) -> Result<{{Name}}Data>;
    
    async fn find_all(&self) -> Result<Vec<{{Name}}Data>>;
    
    async fn find_all_paginated(&self, limit: i64, offset: i64) -> Result<Vec<{{Name}}Data>>;
    
    async fn find_by_name(&self, name: &str) -> Result<Vec<{{Name}}Data>>;
    
    async fn search(&self, query: &str) -> Result<Vec<{{Name}}Data>>;
    
    async fn count(&self) -> Result<i64>;
    
    async fn save(&self, data: &{{Name}}Data) -> Result<{{Name}}Data>;
    
    async fn save_many(&self, data: &[{{Name}}Data]) -> Result<Vec<{{Name}}Data>>;
    
    async fn update(&self, id: i64, data: &{{Name}}Data) -> Result<{{Name}}Data>;
    
    async fn delete(&self, id: i64) -> Result<()>;
    
    async fn delete_many(&self, ids: &[i64]) -> Result<u64>;
}
