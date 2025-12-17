use async_trait::async_trait;
use crate::data::{{name}}_data::{{Name}}Data;

#[async_trait]
pub trait {{Name}}Repository: Send + Sync {
    async fn find_by_id(&self, id: i64) -> Result<{{Name}}Data, Box<dyn std::error::Error>>;
    
    async fn find_all(&self) -> Result<Vec<{{Name}}Data>, Box<dyn std::error::Error>>;
    
    async fn save(&self, data: &{{Name}}Data) -> Result<{{Name}}Data, Box<dyn std::error::Error>>;
    
    async fn update(&self, id: i64, data: &{{Name}}Data) -> Result<{{Name}}Data, Box<dyn std::error::Error>>;
    
    async fn delete(&self, id: i64) -> Result<(), Box<dyn std::error::Error>>;
}
