use std::fs;
use std::path::Path;

use crate::context::Context;

pub mod service;
pub mod usecase;
pub mod repository;
pub mod data;
pub mod adapter;
pub mod handler;
pub mod project;
pub mod dispatch;
pub mod test;


pub fn render(template: &str, name: &str) -> String {
    let pascal = to_pascal_case(name);
    let snake = to_snake_case(name);

    template
        .replace("{{package_name}}", name)  // For Cargo.toml (allows hyphens)
        .replace("{{name}}", &snake)        // For Rust code (underscores only)
        .replace("{{Name}}", &pascal)       // PascalCase
}

pub fn to_snake_case(s: &str) -> String {
    s.replace('-', "_")
}

pub fn to_pascal_case(s: &str) -> String {
    s.split(|c| c == '_' || c == '-')
        .map(|p| {
            let mut c = p.chars();
            match c.next() {
                None => String::new(),
                Some(f) => f.to_uppercase().collect::<String>() + c.as_str(),
            }
        })
        .collect()
}

pub fn write_file(ctx: &Context, path: &str, content: &str) {
    let path = Path::new(path);

    if path.exists() && !ctx.force {
        println!(
            "Skip {} (already exists, use --force to overwrite)",
            path.display()
        );
        return;
    }

    if ctx.dry_run {
        println!("[DRY RUN] Would write {}", path.display());
        return;
    }

    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).unwrap();
    }

    fs::write(path, content).unwrap();
    println!("Created {}", path.display());
}

pub fn update_module_exports(ctx: &Context, mod_path: &str, module_name: &str) {
    if ctx.dry_run {
        return;
    }
    
    let path = Path::new(mod_path);
    let current_content = fs::read_to_string(path).unwrap_or_else(|_| String::new());
    
    let export_line = format!("pub mod {};", module_name);
    if current_content.contains(&export_line) {
        return;
    }
    
    let new_content = if current_content.contains("// Add your modules here") {
        current_content.replace(
            "// Add your modules here",
            &format!("pub mod {};\n// Add your modules here", module_name)
        )
    } else {
        format!("{}\npub mod {};\n", current_content.trim(), module_name)
    };
    
    fs::write(path, new_content).unwrap();
}
