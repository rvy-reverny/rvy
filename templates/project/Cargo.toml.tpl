[package]
name = "{{package_name}}"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["full"] }
axum = "0.7"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
async-trait = "0.1"
chrono = { version = "0.4", features = ["serde"] }

# Database dependencies - uncomment the ones you need
sqlx = { version = "0.8", features = ["runtime-tokio-rustls", "postgres", "mysql", "sqlite", "chrono"] }
mongodb = "3.1"
