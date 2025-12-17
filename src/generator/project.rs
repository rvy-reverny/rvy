use crate::context::Context;
use crate::generator::{render, write_file};
use std::fs;

pub fn generate(ctx: &Context, name: &str) {
    if ctx.dry_run {
        println!("[DRY RUN] Would create project {}", name);
        return;
    }

    // Create project directory
    fs::create_dir_all(name).unwrap();
    println!("Creating project: {}", name);

    // Generate Cargo.toml
    let cargo_template = include_str!("../../templates/project/Cargo.toml.tpl");
    let cargo_content = render(cargo_template, name);
    let cargo_path = format!("{}/Cargo.toml", name);
    write_file(ctx, &cargo_path, &cargo_content);

    // Generate main.rs
    let main_template = include_str!("../../templates/project/main.rs.tpl");
    let main_content = render(main_template, name);
    let main_path = format!("{}/src/main.rs", name);
    write_file(ctx, &main_path, &main_content);

    // Generate lib.rs
    let lib_template = include_str!("../../templates/project/lib.rs.tpl");
    let lib_content = render(lib_template, name);
    let lib_path = format!("{}/src/lib.rs", name);
    write_file(ctx, &lib_path, &lib_content);

    // Create empty module directories
    let dirs = ["service", "usecase", "repository", "data", "adapter", "config", "factory", "handler"];
    for dir in &dirs {
        let mod_path = format!("{}/src/{}/mod.rs", name, dir);
        write_file(ctx, &mod_path, "// Add your modules here\n");
    }

    println!("✓ Project '{}' created successfully!", name);
}
