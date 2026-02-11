use crate::context::Context;
use crate::generator::{render, write_file, update_module_exports};

pub fn generate(ctx: &Context, name: &str, db_type: &str) {
    let template = match db_type.to_lowercase().as_str() {
        "postgres" => include_str!("../../templates/adapter/postgres.rs.tpl"),
        "mysql" => include_str!("../../templates/adapter/mysql.rs.tpl"),
        "mongodb" => include_str!("../../templates/adapter/mongodb.rs.tpl"),
        "sqlite" => include_str!("../../templates/adapter/sqlite.rs.tpl"),
        _ => {
            eprintln!("Error: Unsupported database type '{}'", db_type);
            eprintln!("Supported types: postgres, mysql, mongodb, sqlite");
            return;
        }
    };

    let content = render(template, name);

    let filename = format!("{}_{}.rs", name, db_type.to_lowercase());
    let path = format!("src/adapter/{}", filename);

    write_file(ctx, &path, &content);
    update_module_exports(ctx, "src/adapter/mod.rs", &format!("{}_{}", name, db_type.to_lowercase()));
}

pub fn generate_all(ctx: &Context, name: &str) {
    let db_types = ["postgres", "mysql", "mongodb", "sqlite"];
    
    for db_type in &db_types {
        generate(ctx, name, db_type);
    }
}

pub fn generate_config(ctx: &Context, name: &str) {
    let template = include_str!("../../templates/config/database.rs.tpl");
    let content = render(template, name);
    let path = "src/config/database.rs";
    
    write_file(ctx, path, &content);
    
    // Update mod.rs to export database
    update_module_exports(ctx, "src/config/mod.rs", "database");
}

pub fn generate_factory(ctx: &Context, name: &str) {
    let template = include_str!("../../templates/factory/repository_factory.rs.tpl");
    let content = render(template, name);
    let path = format!("src/factory/{}_factory.rs", name);
    
    write_file(ctx, &path, &content);
    
    // Update mod.rs to export this factory
    let module_name = format!("{}_factory", name);
    update_module_exports(ctx, "src/factory/mod.rs", &module_name);
}

pub fn generate_usage_docs(ctx: &Context, name: &str) {
    // Generate example main
    let main_template = include_str!("../../templates/examples/main_with_crud.rs.tpl");
    let mut main_content = render(main_template, name);
    
    // Replace crate name with actual package name from Cargo.toml
    if let Some(package_name) = get_package_name() {
        let crate_name = package_name.replace('-', "_");
        main_content = main_content.replace("CRATE_NAME", &crate_name);
    }
    
    let main_path = format!("examples/{}_example.rs", name);
    write_file(ctx, &main_path, &main_content);

    // Generate usage documentation
    let doc_template = include_str!("../../templates/examples/USAGE.md.tpl");
    let doc_content = render(doc_template, name);
    let doc_path = format!("docs/{}_USAGE.md", name);
    write_file(ctx, &doc_path, &doc_content);
}

fn get_package_name() -> Option<String> {
    use std::path::Path;
    let cargo_path = "Cargo.toml";
    if !Path::new(cargo_path).exists() {
        return None;
    }
    
    let content = std::fs::read_to_string(cargo_path).ok()?;
    for line in content.lines() {
        if line.trim().starts_with("name") {
            if let Some(name) = line.split('=').nth(1) {
                let name = name.trim().trim_matches('"').trim();
                return Some(name.to_string());
            }
        }
    }
    None
}
