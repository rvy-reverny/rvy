mod service;
mod usecase;
mod repository;
mod data;
mod adapter;
mod config;
mod factory;
mod handler;

use axum::Router;
use std::sync::Arc;
use tokio::net::TcpListener;

use config::database::DatabaseConfig;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🚀 Starting {{Name}} API Server");
    println!("📦 Configure your database with environment variables:");
    println!("   DATABASE_TYPE=postgres|mysql|mongodb|sqlite");
    println!("   DATABASE_URL=<your-database-url>");
    println!("\n💡 Generate API layers with: rvy new-all <name>");
    println!("\n✅ Server ready!\n");

    Ok(())
}
