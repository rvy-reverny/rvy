use mongodb::{Collection, bson::{doc, to_document}, options::{FindOptions, UpdateOptions}};
use async_trait::async_trait;
use futures::stream::TryStreamExt;
use crate::repository::{{name}}::{{Name}}Repository;
use crate::data::{{name}}_data::{{Name}}Data;
use crate::error::{Result, AppError};

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
    async fn find_by_id(&self, id: i64) -> Result<{{Name}}Data> {
        let filter = doc! { "id": id };
        self.collection
            .find_one(filter)
            .await?
            .ok_or_else(|| AppError::NotFound(format!("{{Name}} with id {} not found", id)))
    }

    async fn find_all(&self) -> Result<Vec<{{Name}}Data>> {
        let mut cursor = self.collection.find(doc! {}).await?;
        let mut results = Vec::new();
        
        while let Some(doc) = cursor.try_next().await? {
            results.push(doc);
        }
        
        Ok(results)
    }

    async fn find_all_paginated(&self, limit: i64, offset: i64) -> Result<Vec<{{Name}}Data>> {
        let options = FindOptions::builder()
            .limit(limit)
            .skip(offset as u64)
            .build();
        
        let mut cursor = self.collection.find(doc! {}).with_options(options).await?;
        let mut results = Vec::new();
        
        while let Some(doc) = cursor.try_next().await? {
            results.push(doc);
        }
        
        Ok(results)
    }

    async fn find_by_name(&self, name: &str) -> Result<Vec<{{Name}}Data>> {
        let filter = doc! { "name": name };
        let mut cursor = self.collection.find(filter).await?;
        let mut results = Vec::new();
        
        while let Some(doc) = cursor.try_next().await? {
            results.push(doc);
        }
        
        Ok(results)
    }

    async fn search(&self, query: &str) -> Result<Vec<{{Name}}Data>> {
        let filter = doc! { 
            "name": { 
                "$regex": query, 
                "$options": "i" 
            } 
        };
        let mut cursor = self.collection.find(filter).await?;
        let mut results = Vec::new();
        
        while let Some(doc) = cursor.try_next().await? {
            results.push(doc);
        }
        
        Ok(results)
    }

    async fn count(&self) -> Result<i64> {
        let count = self.collection.count_documents(doc! {}).await?;
        Ok(count as i64)
    }

    async fn save(&self, data: &{{Name}}Data) -> Result<{{Name}}Data> {
        self.collection.insert_one(data).await?;
        Ok(data.clone())
    }

    async fn save_many(&self, data: &[{{Name}}Data]) -> Result<Vec<{{Name}}Data>> {
        if data.is_empty() {
            return Ok(Vec::new());
        }
        
        self.collection.insert_many(data).await?;
        Ok(data.to_vec())
    }

    async fn update(&self, id: i64, data: &{{Name}}Data) -> Result<{{Name}}Data> {
        let filter = doc! { "id": id };
        
        // Properly serialize the entire data object
        let mut update_doc = to_document(data)
            .map_err(|e| AppError::Internal(format!("Serialization error: {}", e)))?;
        
        // Update timestamp using BSON DateTime
        use mongodb::bson::DateTime as BsonDateTime;
        update_doc.insert("updated_at", BsonDateTime::now());
        
        let update = doc! { "$set": update_doc };
        
        let result = self.collection
            .update_one(filter, update)
            .await?;
        
        if result.matched_count == 0 {
            return Err(AppError::NotFound(format!("{{Name}} with id {} not found", id)));
        }
        
        self.find_by_id(id).await
    }

    async fn delete(&self, id: i64) -> Result<()> {
        let filter = doc! { "id": id };
        let result = self.collection.delete_one(filter).await?;
        
        if result.deleted_count == 0 {
            return Err(AppError::NotFound(format!("{{Name}} with id {} not found", id)));
        }
        
        Ok(())
    }

    async fn delete_many(&self, ids: &[i64]) -> Result<u64> {
        if ids.is_empty() {
            return Ok(0);
        }
        
        let filter = doc! { "id": { "$in": ids } };
        let result = self.collection.delete_many(filter).await?;
        Ok(result.deleted_count)
    }
}
