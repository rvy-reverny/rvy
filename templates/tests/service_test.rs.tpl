#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::Arc;
    use crate::usecase::{{name}}_usecase::{{Name}}Usecase;
    use crate::data::{{name}}_data::{{Name}}Data;
    use crate::repository::{{name}}::{{Name}}Repository;
    use async_trait::async_trait;

    // Mock repository for testing
    struct Mock{{Name}}Repository {
        mock_data: Vec<{{Name}}Data>,
    }

    impl Mock{{Name}}Repository {
        fn new() -> Self {
            Self {
                mock_data: vec![
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
        async fn find_by_id(&self, id: i64) -> Result<{{Name}}Data, Box<dyn std::error::Error>> {
            self.mock_data
                .iter()
                .find(|d| d.id == id)
                .cloned()
                .ok_or_else(|| "Not found".into())
        }

        async fn find_all(&self) -> Result<Vec<{{Name}}Data>, Box<dyn std::error::Error>> {
            Ok(self.mock_data.clone())
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

    fn create_test_service() -> {{Name}}Service {
        let repository = Arc::new(Mock{{Name}}Repository::new());
        let usecase = Arc::new({{Name}}Usecase::new(repository));
        {{Name}}Service::new(usecase)
    }

    #[tokio::test]
    async fn test_get_by_id_success() {
        let service = create_test_service();
        let result = service.get_by_id(1).await;
        
        assert!(result.is_ok());
        let data = result.unwrap();
        assert_eq!(data.id, 1);
        assert_eq!(data.name, "Test {{Name}} 1");
    }

    #[tokio::test]
    async fn test_get_by_id_not_found() {
        let service = create_test_service();
        let result = service.get_by_id(999).await;
        
        assert!(result.is_err());
    }

    #[tokio::test]
    async fn test_get_all() {
        let service = create_test_service();
        let result = service.get_all().await;
        
        assert!(result.is_ok());
        let data = result.unwrap();
        assert_eq!(data.len(), 2);
    }

    #[tokio::test]
    async fn test_create() {
        let service = create_test_service();
        let new_data = {{Name}}Data {
            id: 3,
            name: "New {{Name}}".to_string(),
            created_at: Some(chrono::Utc::now()),
            updated_at: Some(chrono::Utc::now()),
        };
        
        let result = service.create(new_data.clone()).await;
        
        assert!(result.is_ok());
        let created = result.unwrap();
        assert_eq!(created.name, new_data.name);
    }

    #[tokio::test]
    async fn test_update() {
        let service = create_test_service();
        let updated_data = {{Name}}Data {
            id: 1,
            name: "Updated {{Name}}".to_string(),
            created_at: Some(chrono::Utc::now()),
            updated_at: Some(chrono::Utc::now()),
        };
        
        let result = service.update(1, updated_data.clone()).await;
        
        assert!(result.is_ok());
        let updated = result.unwrap();
        assert_eq!(updated.name, updated_data.name);
    }

    #[tokio::test]
    async fn test_delete() {
        let service = create_test_service();
        let result = service.delete(1).await;
        
        assert!(result.is_ok());
    }
}
