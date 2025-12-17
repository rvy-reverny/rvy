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


pub fn render(template: &str, name: &str) -> String {
    let pascal = to_pascal_case(name);
    let snake = to_snake_case(name);

    template
        .replace("{{name}}", &snake)
        .replace("{{Name}}", &pascal)
}

fn to_snake_case(s: &str) -> String {
    s.replace('-', "_")
}

fn to_pascal_case(s: &str) -> String {
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
