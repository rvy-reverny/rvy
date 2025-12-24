// Common test utilities and helpers
// This file is shared across integration tests

use std::sync::Arc;
use async_trait::async_trait;

// Re-export everything needed for tests
pub use {{package_name}}::service::{{name}}_service::{{Name}}Service;
pub use {{package_name}}::usecase::{{name}}_usecase::{{Name}}Usecase;
pub use {{package_name}}::repository::{{name}}::{{Name}}Repository;
pub use {{package_name}}::data::{{name}}_data::{{Name}}Data;
pub use {{package_name}}::handler::{{name}}_handler::{{Name}}Handler;

// Mock repository for integration tests
pub struct Mock{{Name}}Repository {
    data: Vec<{{Name}}Data>,
}

impl Mock{{Name}}Repository {
    pub fn new() -> Self {
        Self {
            data: vec![
                {{Name}}Data::new(1, "Test {{Name}} 1".to_string()),
                {{Name}}Data::new(2, "Test {{Name}} 2".to_string()),
            ],
        }
    }
}

#[async_trait]
impl {{Name}}Repository for Mock{{Name}}Repository {
    async fn find_by_id(&self, id: i64) -> Result<{{Name}}Data, Box<dyn std::error::Error>> {
        self.data
            .iter()
            .find(|d| d.id == id)
            .cloned()
            .ok_or_else(|| "Not found".into())
    }

    async fn find_all(&self) -> Result<Vec<{{Name}}Data>, Box<dyn std::error::Error>> {
        Ok(self.data.clone())
    }

    async fn save(&self, data: &{{Name}}Data) -> Result<{{Name}}Data, Box<dyn std::error::Error>> {
        Ok(data.clone())
    }

    async fn update(&self, id: i64, data: &{{Name}}Data) -> Result<{{Name}}Data, Box<dyn std::error::Error>> {
        let mut updated = data.clone();
        updated.id = id;
        Ok(updated)
    }

    async fn delete(&self, _id: i64) -> Result<(), Box<dyn std::error::Error>> {
        Ok(())
    }
}

pub fn create_test_service() -> {{Name}}Service {
    let repository = Arc::new(Mock{{Name}}Repository::new());
    let usecase = Arc::new({{Name}}Usecase::new(repository));
    {{Name}}Service::new(usecase)
}
