// Common test utilities and helpers
// This file is shared across integration tests

use std::sync::Arc;
use async_trait::async_trait;

// Note: Replace 'CRATE_NAME' below with your actual crate name from Cargo.toml
// For now, using entity name as placeholder - you may need to update imports
pub use crate::service::{{name}}_service::{{Name}}Service;
pub use crate::usecase::{{name}}_usecase::{{Name}}Usecase;
pub use crate::repository::{{name}}::{{Name}}Repository;
pub use crate::data::{{name}}_data::{{Name}}Data;
pub use crate::handler::{{name}}_handler::{{Name}}Handler;
pub use crate::error::{Result, AppError};

// Mock repository for integration tests
pub struct Mock{{Name}}Repository {
    data: Vec<{{Name}}Data>,
}

impl Mock{{Name}}Repository {
    pub fn new() -> Self {
        Self {
            data: vec![
                {{Name}}Data {
                    id: 1,
                    name: "Test {{Name}} 1".to_string(),
                    created_at: Some(chrono::Utc::now()),
                    updated_at: Some(chrono::Utc::now()),
                },
                {{Name}}Data {
                    id: 2,
                    name: "Test {{Name}} 2".to_string(),
                    created_at: Some(chrono::Utc::now()),
                    updated_at: Some(chrono::Utc::now()),
                },
            ],
        }
    }
}

#[async_trait]
impl {{Name}}Repository for Mock{{Name}}Repository {
    async fn find_by_id(&self, id: i64) -> Result<{{Name}}Data> {
        self.data
            .iter()
            .find(|d| d.id == id)
            .cloned()
            .ok_or_else(|| AppError::NotFound(format!("{{Name}} with id {} not found", id)))
    }

    async fn find_all(&self) -> Result<Vec<{{Name}}Data>> {
        Ok(self.data.clone())
    }

    async fn find_all_paginated(&self, _limit: i64, _offset: i64) -> Result<Vec<{{Name}}Data>> {
        Ok(self.data.clone())
    }

    async fn find_by_name(&self, name: &str) -> Result<Vec<{{Name}}Data>> {
        Ok(self.data.iter()
            .filter(|d| d.name == name)
            .cloned()
            .collect())
    }

    async fn search(&self, query: &str) -> Result<Vec<{{Name}}Data>> {
        Ok(self.data.iter()
            .filter(|d| d.name.contains(query))
            .cloned()
            .collect())
    }

    async fn count(&self) -> Result<i64> {
        Ok(self.data.len() as i64)
    }

    async fn save(&self, data: &{{Name}}Data) -> Result<{{Name}}Data> {
        Ok(data.clone())
    }

    async fn save_many(&self, data: &[{{Name}}Data]) -> Result<Vec<{{Name}}Data>> {
        Ok(data.to_vec())
    }

    async fn update(&self, id: i64, data: &{{Name}}Data) -> Result<{{Name}}Data> {
        let mut updated = data.clone();
        updated.id = id;
        Ok(updated)
    }

    async fn delete(&self, _id: i64) -> Result<()> {
        Ok(())
    }

    async fn delete_many(&self, _ids: &[i64]) -> Result<u64> {
        Ok(_ids.len() as u64)
    }
}

pub fn create_test_service() -> {{Name}}Service {
    let repository = Arc::new(Mock{{Name}}Repository::new());
    let usecase = Arc::new({{Name}}Usecase::new(repository));
    {{Name}}Service::new(usecase)
}
