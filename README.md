# RVY - Rust Code Generator

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Rust](https://img.shields.io/badge/rust-1.70%2B-orange.svg)](https://www.rust-lang.org/)

A powerful CLI tool for scaffolding production-ready Rust projects with **Clean Architecture**, **REST APIs**, **OpenAPI/Swagger documentation**, and **multiple database support**.

## ✨ Features

- 🏗️ **Clean Architecture** - Service → Usecase → Repository → Adapter pattern
- 🚀 **REST API** - Full CRUD operations with Axum framework
- 📚 **OpenAPI 3.1.0** - Auto-generated Swagger documentation with Authorization
- 🗄️ **Multi-Database** - Runtime switching between PostgreSQL, MySQL, SQLite, MongoDB
- 🔐 **Bearer Auth** - Built-in authorization support in all endpoints
- ⚡ **Async/Await** - Tokio-based async runtime
- 🎯 **Type-Safe** - Full Rust type safety with SQLx compile-time checks
- 📦 **Zero Configuration** - Works out of the box with sensible defaults

## Installation

### From crates.io (Recommended)

```bash
cargo install rvy
```

### From source

```bash
git clone https://github.com/rvy-reverny/rvy.git
cd rvy
cargo install --path .
```

### Verify installation

```bash
rvy --help
```

## Usage

### Create a new project

```bash
rvy new project my_app
```

This creates a new project with the following structure:
```
my_app/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── service/
│   ├── usecase/
│   ├── repository/
│   └── data/
```

### Generate all layers at once (Recommended)

```bash
# Generate complete entity with all layers, database adapters, and REST API
rvy gen-all user
```

This generates:

- ✅ Service layer: `src/service/user_service.rs`
- ✅ Usecase layer: `src/usecase/user_usecase.rs`
- ✅ Repository trait: `src/repository/user.rs`
- ✅ Data model: `src/data/user_data.rs`
- ✅ REST API Handler: `src/handler/user_handler.rs` with OpenAPI annotations
- ✅ Database adapters: `src/adapter/user_{postgres,mysql,mongodb,sqlite}.rs`
- ✅ Factory pattern: `src/factory/user_factory.rs`
- ✅ Database config: `src/config/database.rs`
- ✅ Usage examples: `examples/user_example.rs` and `docs/user_USAGE.md`
- ✅ Auto-updated `main.rs` with routes and Swagger UI

### Generate individual components

```bash
# Generate specific layers
rvy gen service user
rvy gen usecase user
rvy gen repository user
rvy gen data user

# Generate REST API handler with OpenAPI docs
rvy gen handler user

# Generate database adapters
rvy gen adapter user

# Generate factory for runtime DB selection
rvy gen factory user
```

## 🚀 Quick Start

### 1. Create a new project

```bash
rvy new project my_api
cd my_api
```

### 2. Generate your first entity

```bash
rvy gen-all product
```

### 3. Set up database connection

Create a `.env` file:

```env
DATABASE_URL=postgres://user:password@localhost:5432/mydb
# Or use other databases:
# DATABASE_URL=mysql://user:password@localhost:3306/mydb
# DATABASE_URL=sqlite://data.db
# DATABASE_URL=mongodb://localhost:27017/mydb
```

### 4. Run the application

```bash
cargo run
```

### 5. Access Swagger UI

Open your browser: **http://127.0.0.1:3000/swagger-ui**

You'll see:
- 📚 Complete API documentation
- 🔐 Authorization button (click to add Bearer token)
- 🧪 Try it out feature for testing endpoints
- 📋 Multiple API specs (one per entity)

## 📊 Generated Project Structure

```text
my_api/
├── Cargo.toml
├── .env
├── src/
│   ├── main.rs              # Auto-configured with routes & Swagger
│   ├── lib.rs
│   ├── service/             # Business logic
│   │   ├── mod.rs
│   │   └── product_service.rs
│   ├── usecase/             # Application use cases
│   │   ├── mod.rs
│   │   └── product_usecase.rs
│   ├── repository/          # Data access traits
│   │   ├── mod.rs
│   │   └── product.rs
│   ├── data/                # DTOs with OpenAPI schemas
│   │   ├── mod.rs
│   │   └── product_data.rs
│   ├── handler/             # REST API with OpenAPI annotations
│   │   ├── mod.rs
│   │   └── product_handler.rs
│   ├── adapter/             # Database implementations
│   │   ├── mod.rs
│   │   ├── product_postgres.rs
│   │   ├── product_mysql.rs
│   │   ├── product_mongodb.rs
│   │   └── product_sqlite.rs
│   ├── factory/             # Runtime DB selection
│   │   ├── mod.rs
│   │   └── product_factory.rs
│   └── config/
│       ├── mod.rs
│       └── database.rs      # DB configuration
├── examples/
│   └── product_example.rs
└── docs/
    └── product_USAGE.md
```

## 🔧 Options

- `--dry-run`: Preview what will be generated without writing files
- `--force`: Overwrite existing files

## 💡 Examples

```bash
# Preview generation
rvy gen-all user --dry-run

# Force overwrite existing files
rvy gen handler user --force

# Generate multiple entities
rvy gen-all product
rvy gen-all user
rvy gen-all order
```

## 🏗️ Architecture

RVY follows **Clean Architecture** principles with clear separation of concerns:

```text
Handler (REST API)
    ↓
Service (Business Logic)
    ↓
Usecase (Application Logic)
    ↓
Repository (Data Access Interface)
    ↓
Adapter (Database Implementation)
    ↓
Database (PostgreSQL/MySQL/SQLite/MongoDB)
```

### Layer Responsibilities

- **Handler**: REST API endpoints, request/response handling, OpenAPI documentation
- **Service**: Business rules and domain logic
- **Usecase**: Application-specific business rules
- **Repository**: Data access interface (trait)
- **Adapter**: Concrete database implementations
- **Data**: DTOs with serialization and validation
- **Factory**: Runtime database adapter selection
- **Config**: Application configuration and environment variables

## 📚 API Documentation

Generated APIs include:

### Endpoints (per entity)

- `GET /{entity}s` - Get all records
- `GET /{entity}s/{id}` - Get record by ID
- `POST /{entity}s` - Create new record
- `PUT /{entity}s/{id}` - Update record
- `DELETE /{entity}s/{id}` - Delete record

### OpenAPI Features

- ✅ **OpenAPI 3.1.0** specification
- ✅ **Bearer Authentication** - Token-based auth on all endpoints
- ✅ **Request/Response Schemas** - Full type definitions
- ✅ **Example Values** - Sample data for testing
- ✅ **Multiple API Specs** - Separate docs per entity
- ✅ **Interactive Testing** - Try endpoints directly from Swagger UI

## 🗄️ Database Support

### Supported Databases

| Database   | Connection String Example                          |
|------------|---------------------------------------------------|
| PostgreSQL | `postgres://user:pass@localhost:5432/db`         |
| MySQL      | `mysql://user:pass@localhost:3306/db`            |
| SQLite     | `sqlite://data.db`                               |
| MongoDB    | `mongodb://localhost:27017/db`                   |

### Runtime Selection

The database adapter is selected at runtime based on the `DATABASE_URL` environment variable. No need to recompile for different databases!

```rust
// Automatically detected from DATABASE_URL
let config = DatabaseConfig::from_env();
let repository = create_product_repository(&config).await?;
```

## 🔐 Authentication

All generated endpoints include Bearer token authentication:

```rust
#[utoipa::path(
    get,
    path = "/products",
    responses(/* ... */),
    security(("bearer_auth" = [])) // 🔒 Requires authentication
)]
```

To test with Swagger UI:
1. Click **Authorize** button 🔓
2. Enter: `Bearer your-token-here`
3. Click **Authorize**
4. All requests will include the token

## 🛠️ Technology Stack

- **Web Framework**: [Axum](https://github.com/tokio-rs/axum) 0.7
- **Async Runtime**: [Tokio](https://tokio.rs/)
- **Database**: [SQLx](https://github.com/launchbadge/sqlx) 0.8, [MongoDB](https://github.com/mongodb/mongo-rust-driver) 3.1
- **OpenAPI**: [utoipa](https://github.com/juhaku/utoipa) 5.4 (OpenAPI 3.1.0)
- **Swagger UI**: [utoipa-swagger-ui](https://github.com/juhaku/utoipa) 8.1
- **Serialization**: [serde](https://serde.rs/)
- **Date/Time**: [chrono](https://github.com/chronotope/chrono)
- **Environment**: [dotenvy](https://github.com/allan2/dotenvy)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ using Rust
- Inspired by Clean Architecture principles
- OpenAPI 3.1.0 specification
- Community feedback and contributions

---

**Made with 🦀 Rust**
