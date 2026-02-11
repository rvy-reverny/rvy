use crate::context::Context;
use crate::generator::render;
use std::fs;
use std::path::Path;

pub fn generate_unit_tests(ctx: &Context, name: &str) {
    let template = include_str!("../../templates/tests/service_test.rs.tpl");
    let content = render(template, name);
    
    // Append tests to service file
    let service_path = format!("src/service/{}_service.rs", name);
    
    if ctx.dry_run {
        println!("[DRY RUN] Would add unit tests to {}", service_path);
        return;
    }
    
    if !Path::new(&service_path).exists() {
        eprintln!("Error: {} does not exist. Generate service first.", service_path);
        return;
    }
    
    let mut current_content = fs::read_to_string(&service_path).unwrap();
    
    // Check if tests already exist
    if current_content.contains("#[cfg(test)]") {
        if !ctx.force {
            println!("Skip adding tests to {} (already exists, use --force to overwrite)", service_path);
            return;
        }
        // Remove existing test module
        if let Some(pos) = current_content.find("#[cfg(test)]") {
            current_content = current_content[..pos].trim_end().to_string();
        }
    }
    
    // Append test module
    current_content.push_str("\n\n");
    current_content.push_str(&content);
    
    fs::write(&service_path, current_content).unwrap();
    println!("Added unit tests to {}", service_path);
}

pub fn generate_integration_tests(ctx: &Context, name: &str) {
    let template = include_str!("../../templates/tests/integration_test.rs.tpl");
    let content = render(template, name);
    
    let test_path = format!("tests/{}_test.rs", name);
    
    if ctx.dry_run {
        println!("[DRY RUN] Would create {}", test_path);
        return;
    }
    
    let path = Path::new(&test_path);
    
    if path.exists() && !ctx.force {
        println!("Skip {} (already exists, use --force to overwrite)", test_path);
        return;
    }
    
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).unwrap();
    }
    
    fs::write(path, content).unwrap();
    println!("Created {}", test_path);
    
    // Also create common test utilities if they don't exist
    create_test_common(ctx, name);
}

fn create_test_common(_ctx: &Context, name: &str) {
    let common_path = "tests/common.rs";
    
    if Path::new(common_path).exists() {
        return; // Already exists
    }
    
    // Read package name from Cargo.toml
    let package_name = get_package_name().unwrap_or_else(|| name.to_string());
    
    let template = include_str!("../../templates/tests/common.rs.tpl");
    let mut content = render(template, name);
    
    // Replace placeholders with actual crate name (snake_case version)
    let crate_name = package_name.replace('-', "_");
    content = content.replace("crate::", &format!("{}::", crate_name));
    
    fs::write(common_path, content).unwrap();
    println!("Created {}", common_path);
}

fn get_package_name() -> Option<String> {
    let cargo_path = "Cargo.toml";
    if !Path::new(cargo_path).exists() {
        return None;
    }
    
    let content = fs::read_to_string(cargo_path).ok()?;
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

pub fn generate_all_tests(ctx: &Context, name: &str) {
    generate_unit_tests(ctx, name);
    generate_integration_tests(ctx, name);
}
