use crate::context::Context;
use crate::generator::{service, usecase, repository, data, adapter, handler, test, migration};

pub enum GenKind {
    Service,
    Usecase,
    Repository,
    Data,
    Handler,
    Adapter(String), // database type: postgres, mysql, mongodb, sqlite
    AdapterAll,
    Config,
    Factory,
    Example,
    Test,           // Unit tests
    IntegrationTest, // Integration tests
    AllTests,       // Both unit and integration tests
    Migration(String), // Migration for specific database
    MigrationAll,   // Migrations for all databases
}

pub fn dispatch(kind: GenKind, ctx: &Context, name: &str) {
    match kind {
        GenKind::Service => service::generate(ctx, name),
        GenKind::Usecase => usecase::generate(ctx, name),
        GenKind::Repository => repository::generate(ctx, name),
        GenKind::Data => data::generate(ctx, name),
        GenKind::Handler => handler::generate(ctx, name),
        GenKind::Adapter(db_type) => adapter::generate(ctx, name, &db_type),
        GenKind::AdapterAll => adapter::generate_all(ctx, name),
        GenKind::Config => adapter::generate_config(ctx, name),
        GenKind::Factory => adapter::generate_factory(ctx, name),
        GenKind::Example => adapter::generate_usage_docs(ctx, name),
        GenKind::Test => test::generate_unit_tests(ctx, name),
        GenKind::IntegrationTest => test::generate_integration_tests(ctx, name),
        GenKind::AllTests => test::generate_all_tests(ctx, name),
        GenKind::Migration(db_type) => {
            if let Err(e) = migration::generate_migration(ctx, name, &db_type) {
                eprintln!("❌ Error generating migration: {}", e);
                std::process::exit(1);
            }
        }
        GenKind::MigrationAll => {
            if let Err(e) = migration::generate_migration(ctx, name, "all") {
                eprintln!("❌ Error generating migrations: {}", e);
                std::process::exit(1);
            }
        }
    }
}

pub fn generate_all(ctx: &Context, name: &str) {
    dispatch(GenKind::Service, ctx, name);
    dispatch(GenKind::Usecase, ctx, name);
    dispatch(GenKind::Repository, ctx, name);
    dispatch(GenKind::Data, ctx, name);
    dispatch(GenKind::Handler, ctx, name);
    dispatch(GenKind::AdapterAll, ctx, name);
    dispatch(GenKind::Config, ctx, name);
    dispatch(GenKind::Factory, ctx, name);
    dispatch(GenKind::Example, ctx, name);
    dispatch(GenKind::AllTests, ctx, name); // Add tests
    dispatch(GenKind::MigrationAll, ctx, name); // Add migrations for all databases
}
