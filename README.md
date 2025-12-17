# RVY - Rust Code Generator

A CLI tool for scaffolding Rust projects with clean architecture patterns.

## Installation

```bash
cargo install --path .
```

Or run directly:
```bash
cargo run -- <command>
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

### Generate all layers at once

```bash
rvy new-all user
```

This generates:
- `src/service/user_service.rs`
- `src/usecase/user_usecase.rs`
- `src/repository/user_repository.rs`

### Generate individual components

```bash
# Generate a service
rvy gen service user

# Generate a usecase
rvy gen usecase user

# Generate a repository
rvy gen repository user

# Generate a data model
rvy gen data user
```

## Options

- `--dry-run`: Preview what will be generated without writing files
- `--force`: Overwrite existing files

## Examples

```bash
# Preview generation
rvy gen service user --dry-run

# Force overwrite
rvy gen service user --force

# Generate all layers with dry-run
rvy new-all order --dry-run
```

## Architecture

RVY follows clean architecture principles:

- **Service**: Business logic layer
- **Usecase**: Application use cases
- **Repository**: Data access layer
- **Data**: Data transfer objects

## License

MIT
