use crate::context::Context;
use crate::generator::{render, write_file, update_module_exports, to_snake_case, to_pascal_case};
use std::fs;

pub fn generate(ctx: &Context, name: &str) {
    let template = include_str!("../../templates/handler.rs.tpl");

    let content = render(template, name);

    let path = format!("src/handler/{}_handler.rs", name);

    write_file(ctx, &path, &content);
    update_module_exports(ctx, "src/handler/mod.rs", &format!("{}_handler", name));
    update_main_router(ctx, name);
}

fn update_main_router(ctx: &Context, name: &str) {
    let main_path = "src/main.rs";
    
    if ctx.dry_run {
        println!("Would update {} with {} routes", main_path, name);
        return;
    }
    
    let Ok(content) = fs::read_to_string(main_path) else {
        return;
    };
    
    let snake = to_snake_case(name);
    let pascal = to_pascal_case(name);
    
    // Check if handler is already imported
    if content.contains(&format!("use handler::{}_handler", snake)) {
        return; // Already added
    }
    
    let mut new_content = content.clone();
    
    // Add import after handler module declaration
    if !content.contains("use handler::") {
        // First handler - add imports section
        let imports = if ctx.is_new_all {
            // new-all: Add all necessary imports
            format!("mod handler;\n\nuse axum::Router;\nuse std::sync::Arc;\nuse tokio::net::TcpListener;\n\nuse config::database::DatabaseConfig;\nuse factory::{}_factory;\nuse service::{}_service::{}Service;\nuse usecase::{}_usecase::{}Usecase;\nuse handler::{}_handler::{}Handler;", 
                snake, snake, pascal, snake, pascal, snake, pascal)
        } else {
            // gen handler: Just handler import
            format!("mod handler;\n\nuse axum::Router;\nuse std::sync::Arc;\nuse tokio::net::TcpListener;\nuse handler::{}_handler::{}Handler;", snake, pascal)
        };
        
        new_content = new_content.replace("mod handler;", &imports);
    } else {
        // Add to existing imports
        let import_line = format!("use handler::{}_handler::{}Handler;", snake, pascal);
        if let Some(pos) = new_content.find("use handler::") {
            if let Some(end) = new_content[pos..].find('\n') {
                let insert_pos = pos + end + 1;
                new_content.insert_str(insert_pos, &format!("{}\n", import_line));
            }
        }
    }
    
    // Replace the main function with actual router setup
    if content.contains("println!(\"🚀 Welcome") {
        let new_main = if ctx.is_new_all {
            // new-all: Generate complete working code
            format!(r#"
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {{
    // Load environment variables from .env file
    dotenvy::dotenv().ok();
    
    println!("🚀 Starting API Server...");
    
    // Initialize services
    let config = config::database::DatabaseConfig::from_env();
    let repository = factory::{}_factory::create_{}_repository(&config).await?;
    let usecase = Arc::new(usecase::{}_usecase::{}Usecase::new(repository));
    let service = Arc::new(service::{}_service::{}Service::new(usecase));
    
    let app = Router::new()
        .merge({}Handler::routes(service));
    
    let addr = "127.0.0.1:3000";
    println!("✅ Server listening on http://{{}}", addr);
    
    let listener = TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;
    
    Ok(())
}}
"#, snake, snake, snake, pascal, snake, pascal, pascal)
        } else {
            // gen handler: Generate with TODO comments
            format!(r#"
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {{
    println!("🚀 Starting API Server...");
    
    // TODO: Initialize your services here
    // Example:
    // let config = config::database::DatabaseConfig::from_env();
    // let repository = factory::{}_factory::create_{}_repository(&config).await?;
    // let usecase = Arc::new(usecase::{}_usecase::{}Usecase::new(repository));
    // let service = Arc::new(service::{}_service::{}Service::new(usecase));
    
    let app = Router::new();
        // .merge({}Handler::routes(service));
    
    let addr = "127.0.0.1:3000";
    println!("✅ Server listening on http://{{}}", addr);
    
    let listener = TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;
    
    Ok(())
}}
"#, snake, snake, snake, pascal, snake, pascal, pascal)
        };
        
        // Find and replace main function
        if let Some(start) = new_content.find("#[tokio::main]") {
            if let Some(end) = new_content[start..].find("\n}\n") {
                new_content.replace_range(start..start + end + 2, &new_main);
            }
        }
    }
    
    if let Err(e) = fs::write(main_path, new_content) {
        eprintln!("Warning: Failed to update {}: {}", main_path, e);
    } else {
        println!("Updated {} with {} routes", main_path, name);
    }
}
