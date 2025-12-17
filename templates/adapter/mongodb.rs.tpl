use mongodb::{Collection, bson::doc};
use async_trait::async_trait;
use crate::repository::{{name}}::{{Name}}Repository;
use crate::data::{{name}}_data::{{Name}}Data;

pub struct Mongo{{Name}}Repository {
    collection: Collection<{{Name}}Data>,
}

impl Mongo{{Name}}Repository {
    pub fn new(collection: Collection<{{Name}}Data>) -> Self {
        Self { collection }
    }
}

#[async_trait]
impl {{Name}}Repository for Mongo{{Name}}Repository {
    async fn find_by_id(&self, id: i64) -> Result<{{Name}}Data, Box<dyn std::error::Error>> {
        let filter = doc! { "id": id };
        let result = self.collection
            .find_one(filter)
            .await?
            .ok_or("Document not found")?;
        
        Ok(result)
    }

    async fn find_all(&self) -> Result<Vec<{{Name}}Data>, Box<dyn std::error::Error>> {
        let mut cursor = self.collection.find(doc! {}).await?;
        let mut results = Vec::new();
        
        while cursor.advance().await? {
            results.push(cursor.deserialize_current()?);
        }
        
        Ok(results)
    }

    async fn save(&self, data: &{{Name}}Data) -> Result<{{Name}}Data, Box<dyn std::error::Error>> {
        self.collection.insert_one(data).await?;
        Ok(data.clone())
    }

    async fn update(&self, id: i64, data: &{{Name}}Data) -> Result<{{Name}}Data, Box<dyn std::error::Error>> {
        let filter = doc! { "id": id };
        let update = doc! { "$set": { "id": data.id } };
        
        self.collection
            .update_one(filter, update)
            .await?;
        
        self.find_by_id(id).await
    }

    async fn delete(&self, id: i64) -> Result<(), Box<dyn std::error::Error>> {
        let filter = doc! { "id": id };
        self.collection.delete_one(filter).await?;
        Ok(())
    }
}
