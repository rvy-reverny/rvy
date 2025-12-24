use crate::context::Context;
use std::fs;
use std::io::Write;
use std::path::Path;

pub fn generate_postgres_migration(ctx: &Context, name: &str) -> std::io::Result<()> {
    let template = include_str!("../../templates/migrations/postgres_create_table.sql.tpl");
    let content = template.replace("{{name}}", name);
    
    let migrations_dir = Path::new("migrations");
    fs::create_dir_all(migrations_dir)?;
    
    let timestamp = chrono::Utc::now().format("%Y%m%d%H%M%S");
    let filename = format!("{}_create_{}s_table_postgres.sql", timestamp, name);
    let file_path = migrations_dir.join(&filename);
    
    if file_path.exists() && !ctx.force {
        println!("⏭️  Skipping PostgreSQL migration (already exists): {}", filename);
        return Ok(());
    }
    
    if ctx.dry_run {
        println!("🔍 Would generate PostgreSQL migration: {}", filename);
        return Ok(());
    }
    
    let mut file = fs::File::create(&file_path)?;
    file.write_all(content.as_bytes())?;
    
    println!("✅ Generated PostgreSQL migration: {}", filename);
    Ok(())
}

pub fn generate_mysql_migration(ctx: &Context, name: &str) -> std::io::Result<()> {
    let template = include_str!("../../templates/migrations/mysql_create_table.sql.tpl");
    let content = template.replace("{{name}}", name);
    
    let migrations_dir = Path::new("migrations");
    fs::create_dir_all(migrations_dir)?;
    
    let timestamp = chrono::Utc::now().format("%Y%m%d%H%M%S");
    let filename = format!("{}_create_{}s_table_mysql.sql", timestamp, name);
    let file_path = migrations_dir.join(&filename);
    
    if file_path.exists() && !ctx.force {
        println!("⏭️  Skipping MySQL migration (already exists): {}", filename);
        return Ok(());
    }
    
    if ctx.dry_run {
        println!("🔍 Would generate MySQL migration: {}", filename);
        return Ok(());
    }
    
    let mut file = fs::File::create(&file_path)?;
    file.write_all(content.as_bytes())?;
    
    println!("✅ Generated MySQL migration: {}", filename);
    Ok(())
}

pub fn generate_sqlite_migration(ctx: &Context, name: &str) -> std::io::Result<()> {
    let template = include_str!("../../templates/migrations/sqlite_create_table.sql.tpl");
    let content = template.replace("{{name}}", name);
    
    let migrations_dir = Path::new("migrations");
    fs::create_dir_all(migrations_dir)?;
    
    let timestamp = chrono::Utc::now().format("%Y%m%d%H%M%S");
    let filename = format!("{}_create_{}s_table_sqlite.sql", timestamp, name);
    let file_path = migrations_dir.join(&filename);
    
    if file_path.exists() && !ctx.force {
        println!("⏭️  Skipping SQLite migration (already exists): {}", filename);
        return Ok(());
    }
    
    if ctx.dry_run {
        println!("🔍 Would generate SQLite migration: {}", filename);
        return Ok(());
    }
    
    let mut file = fs::File::create(&file_path)?;
    file.write_all(content.as_bytes())?;
    
    println!("✅ Generated SQLite migration: {}", filename);
    Ok(())
}

pub fn generate_mongodb_setup(ctx: &Context, name: &str) -> std::io::Result<()> {
    let template = include_str!("../../templates/migrations/mongodb_setup.rs.tpl");
    let content = template.replace("{{name}}", name);
    
    let migrations_dir = Path::new("migrations");
    fs::create_dir_all(migrations_dir)?;
    
    let filename = format!("setup_{}s_collection.rs", name);
    let file_path = migrations_dir.join(&filename);
    
    if file_path.exists() && !ctx.force {
        println!("⏭️  Skipping MongoDB setup (already exists): {}", filename);
        return Ok(());
    }
    
    if ctx.dry_run {
        println!("🔍 Would generate MongoDB setup script: {}", filename);
        return Ok(());
    }
    
    let mut file = fs::File::create(&file_path)?;
    file.write_all(content.as_bytes())?;
    
    println!("✅ Generated MongoDB setup script: {}", filename);
    Ok(())
}

pub fn generate_migration(ctx: &Context, name: &str, db_type: &str) -> std::io::Result<()> {
    match db_type {
        "postgres" => generate_postgres_migration(ctx, name),
        "mysql" => generate_mysql_migration(ctx, name),
        "sqlite" => generate_sqlite_migration(ctx, name),
        "mongodb" => generate_mongodb_setup(ctx, name),
        "all" => {
            generate_postgres_migration(ctx, name)?;
            generate_mysql_migration(ctx, name)?;
            generate_sqlite_migration(ctx, name)?;
            generate_mongodb_setup(ctx, name)?;
            Ok(())
        }
        _ => {
            eprintln!("❌ Unknown database type: {}", db_type);
            eprintln!("   Supported types: postgres, mysql, sqlite, mongodb, all");
            std::process::exit(1);
        }
    }
}
