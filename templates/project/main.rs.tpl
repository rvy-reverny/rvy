mod service;
mod usecase;
mod repository;
mod data;
mod adapter;
mod config;
mod factory;
mod handler;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🚀 Welcome to {{Name}}!");
    println!("\n📝 Generate your first entity with:");
    println!("   rvy gen-all <entity-name>");
    println!("\n📖 Example:");
    println!("   rvy gen-all user");
    println!("\n✨ This will generate:");
    println!("   • Service layer");
    println!("   • Usecase layer");
    println!("   • Repository trait");
    println!("   • Data model");
    println!("   • REST API handlers");
    println!("   • Database adapters (Postgres, MySQL, MongoDB, SQLite)");
    println!("   • Factory for runtime DB selection");
    println!("   • Example usage in examples/ folder");
    println!("\n📚 Check examples/ and docs/ folders after generation for usage instructions!");

    Ok(())
}
