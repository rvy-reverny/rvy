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
            // new-all: Add all necessary imports including Swagger UI
            format!("mod handler;\n\nuse axum::Router;\nuse std::sync::Arc;\nuse tokio::net::TcpListener;\nuse utoipa::OpenApi;\nuse utoipa_swagger_ui::SwaggerUi;\n\nuse config::database::DatabaseConfig;\nuse factory::{}_factory;\nuse service::{}_service::{}Service;\nuse usecase::{}_usecase::{}Usecase;\nuse handler::{}_handler::{{{}Handler, {}ApiDoc}};", 
                snake, snake, pascal, snake, pascal, snake, pascal, pascal)
        } else {
            // gen handler: Just handler import with Swagger
            format!("mod handler;\n\nuse axum::Router;\nuse std::sync::Arc;\nuse tokio::net::TcpListener;\nuse utoipa::OpenApi;\nuse utoipa_swagger_ui::SwaggerUi;\nuse handler::{}_handler::{{{}Handler, {}ApiDoc}};", snake, pascal, pascal)
        };
        
        new_content = new_content.replace("mod handler;", &imports);
    } else {
        // Add to existing imports - update to include ApiDoc and other dependencies
        let import_line = format!("use handler::{}_handler::{{{}Handler, {}ApiDoc}};", snake, pascal, pascal);
        if let Some(pos) = new_content.find("use handler::") {
            // Find the last handler import line
            let mut last_import_end = pos;
            let mut search_from = pos;
            while let Some(next_pos) = new_content[search_from..].find("use handler::") {
                let actual_pos = search_from + next_pos;
                if let Some(end) = new_content[actual_pos..].find('\n') {
                    last_import_end = actual_pos + end + 1;
                    search_from = last_import_end;
                } else {
                    break;
                }
            }
            new_content.insert_str(last_import_end, &format!("{}\n", import_line));
        }
        
        // Add factory, service, usecase imports if doing new-all
        if ctx.is_new_all {
            // Add after handler imports if they don't exist yet
            if !new_content.contains(&format!("use factory::{}_factory", snake)) {
                if let Some(last_import) = new_content.rfind("use handler::") {
                    if let Some(end) = new_content[last_import..].find('\n') {
                        let insert_at = last_import + end + 1;
                        new_content.insert_str(insert_at, &format!("use factory::{}_factory;\n", snake));
                    }
                }
            }
            if !new_content.contains(&format!("use service::{}_service", snake)) {
                if let Some(last_import) = new_content.rfind("use factory::") {
                    if let Some(end) = new_content[last_import..].find('\n') {
                        let insert_at = last_import + end + 1;
                        new_content.insert_str(insert_at, &format!("use service::{}_service::{}Service;\n", snake, pascal));
                    }
                }
            }
            if !new_content.contains(&format!("use usecase::{}_usecase", snake)) {
                if let Some(last_import) = new_content.rfind("use service::") {
                    if let Some(end) = new_content[last_import..].find('\n') {
                        let insert_at = last_import + end + 1;
                        new_content.insert_str(insert_at, &format!("use usecase::{}_usecase::{}Usecase;\n", snake, pascal));
                    }
                }
            }
        }
    }
    
    // Replace or update the main function
    if content.contains("println!(\"🚀 Welcome") {
        // First handler - generate complete main function
        let new_main = if ctx.is_new_all {
            // new-all: Generate complete working code with Swagger UI
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
    
    // Merge OpenAPI docs
    let openapi = {}ApiDoc::openapi();
    
    let app = Router::new()
        .merge({}Handler::routes(service))
        .merge(SwaggerUi::new("/swagger-ui").url("/api-docs/openapi.json", openapi));
    
    let addr = "127.0.0.1:3000";
    println!("✅ Server listening on http://{{}}", addr);
    println!("📚 Swagger UI available at http://{{}}/swagger-ui", addr);
    
    let listener = TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;
    
    Ok(())
}}
"#, snake, snake, snake, pascal, snake, pascal, pascal, pascal)
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
    } else if ctx.is_new_all {
        // Additional handler - merge with existing handlers
        // Add service initialization
        let service_init = format!("    let repository_{} = factory::{}_factory::create_{}_repository(&config).await?;\n    let usecase_{} = Arc::new(usecase::{}_usecase::{}Usecase::new(repository_{}));\n    let service_{} = Arc::new(service::{}_service::{}Service::new(usecase_{}));",
            snake, snake, snake, snake, snake, pascal, snake, snake, snake, pascal, snake);
        
        // Find where to insert service initialization (after last service)
        if let Some(pos) = new_content.find("let service") {
            // Find last service declaration
            let mut last_service_end = pos;
            let mut search_from = pos;
            while let Some(next) = new_content[search_from..].find("let service") {
                let actual_pos = search_from + next;
                if let Some(end) = new_content[actual_pos..].find(";\n") {
                    last_service_end = actual_pos + end + 2;
                    search_from = last_service_end;
                } else {
                    break;
                }
            }
            new_content.insert_str(last_service_end, &format!("\n{}\n", service_init));
        }
        
        // Add additional OpenAPI doc variable
        if let Some(pos) = new_content.find("let openapi = ") {
            if let Some(end_pos) = new_content[pos..].find("ApiDoc::openapi();") {
                let line_end = pos + end_pos + "ApiDoc::openapi();".len();
                // Add new openapi variable after existing one
                new_content.insert_str(line_end, &format!("\n    let openapi_{} = {}ApiDoc::openapi();", snake, pascal));
            }
        }
        
        // Update SwaggerUi to use multiple OpenAPI specs by creating combined docs
        // We need to merge at the Swagger UI level, not at OpenAPI level
        // For now, we'll just show the latest one (limitation of utoipa-swagger-ui 8.x)
        if let Some(swagger_start) = new_content.find(".merge(SwaggerUi::new(\"/swagger-ui\").url(\"/api-docs/openapi.json\", openapi))") {
            // Replace with multiple URL endpoints
            let swagger_end = swagger_start + ".merge(SwaggerUi::new(\"/swagger-ui\").url(\"/api-docs/openapi.json\", openapi))".len();
            
            // Collect all ApiDoc names
            let mut api_docs = Vec::new();
            let mut search_from = 0;
            while let Some(pos) = new_content[search_from..].find("let openapi") {
                let actual_pos = search_from + pos;
                if let Some(equals) = new_content[actual_pos..].find(" = ") {
                    let var_start = actual_pos + "let ".len();
                    let var_end = actual_pos + equals;
                    let var_name = &new_content[var_start..var_end];
                    if var_name.starts_with("openapi") {
                        api_docs.push(var_name.to_string());
                    }
                }
                search_from = actual_pos + 1;
            }
            
            if api_docs.len() > 1 {
                // Build multiple URL calls for SwaggerUI
                let urls: Vec<String> = api_docs.iter().enumerate().map(|(i, doc_var)| {
                    let name = if doc_var == "openapi" {
                        // First one without suffix - need to extract from earlier in code
                        // Look for "ProductApiDoc::openapi()" pattern
                        if let Some(pos) = new_content.find(&format!("{} = ", doc_var)) {
                            if let Some(api_start) = new_content[pos..].find("ApiDoc::openapi()") {
                                let before = &new_content[pos..pos + api_start];
                                if let Some(name_start) = before.rfind(char::is_alphabetic) {
                                    let full_before = &new_content[..pos + api_start];
                                    if let Some(name_start_pos) = full_before.rfind(char::is_uppercase) {
                                        let entity_name = &new_content[name_start_pos..pos + api_start];
                                        entity_name.replace("ApiDoc", "").to_lowercase()
                                    } else {
                                        "api".to_string()
                                    }
                                } else {
                                    "api".to_string()
                                }
                            } else {
                                "api".to_string()
                            }
                        } else {
                            "api".to_string()
                        }
                    } else {
                        doc_var.replace("openapi_", "")
                    };
                    format!(".url(\"/api-docs/{}.json\", {})", name, doc_var)
                }).collect();
                
                let new_swagger = format!(".merge(SwaggerUi::new(\"/swagger-ui\"){})", urls.join(""));
                new_content.replace_range(swagger_start..swagger_end, &new_swagger);
            }
        }
        
        // Merge routes - find the last route merge before SwaggerUi
        if let Some(app_pos) = new_content.find("let app = Router::new()") {
            if let Some(swagger_pos) = new_content[app_pos..].find(".merge(SwaggerUi::") {
                let insert_at = app_pos + swagger_pos;
                // Insert route before SwaggerUi with proper indentation
                new_content.insert_str(insert_at, &format!(".merge({}Handler::routes(service_{}))\n        ", pascal, snake));
            }
        }
    }
    
    if let Err(e) = fs::write(main_path, new_content) {
        eprintln!("Warning: Failed to update {}: {}", main_path, e);
    } else {
        println!("Updated {} with {} routes", main_path, name);
    }
}
