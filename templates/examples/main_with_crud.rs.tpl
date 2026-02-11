// Example main.rs with complete API setup
// Copy this to your main.rs file to get a working API server

use CRATE_NAME::{
    config::database::DatabaseConfig,
    factory::{{name}}_factory::create_{{name}}_repository,
    usecase::{{name}}_usecase::{{Name}}Usecase,
    service::{{name}}_service::{{Name}}Service,
    handler::{{name}}_handler::{{Name}}Handler,
};
use axum::Router;
use std::sync::Arc;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Load configuration from environment
    let config = DatabaseConfig::from_env();
    
    println!("🚀 Starting {{Name}} API Server");
    println!("📦 Database: {:?}", config.db_type);

    // Initialize layers using dependency injection
    let repository = create_{{name}}_repository(&config).await?;
    let usecase = Arc::new({{Name}}Usecase::new(repository));
    let service = Arc::new({{Name}}Service::new(usecase));

    // Create API routes
    let app = Router::new()
        .nest("/api", {{Name}}Handler::routes(service))
        .route("/", axum::routing::get(|| async { "{{Name}} API Server" }))
        .route("/health", axum::routing::get(|| async { "OK" }));

    // Start server
    let addr = std::env::var("SERVER_ADDRESS")
        .unwrap_or_else(|_| "0.0.0.0:3000".to_string());
    
    println!("✅ Server listening on http://{}", addr);
    println!("\n📚 API Endpoints:");
    println!("  GET    /api/{{name}}s       - List all");
    println!("  GET    /api/{{name}}s/:id   - Get by ID");
    println!("  POST   /api/{{name}}s       - Create new");
    println!("  PUT    /api/{{name}}s/:id   - Update");
    println!("  DELETE /api/{{name}}s/:id   - Delete");
    println!("\n💡 Health check: http://{}/health\n", addr);

    let listener = TcpListener::bind(&addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}
