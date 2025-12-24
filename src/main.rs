use clap::{Parser, Subcommand};

mod context;
mod generator;

use context::Context;
use generator::dispatch::{dispatch, generate_all, GenKind};

#[derive(Parser)]
#[command(name = "rvy")]
#[command(about = "Rust code generator CLI", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    /// Preview what will be generated without writing files
    #[arg(long, global = true)]
    dry_run: bool,

    /// Overwrite existing files
    #[arg(long, global = true)]
    force: bool,
}

#[derive(Subcommand)]
enum Commands {
    /// Create a new project or component
    New {
        #[command(subcommand)]
        command: NewCommands,
    },

    /// Generate all layers (service, usecase, repository, data, handler, adapters)
    #[command(name = "gen-all")]
    GenAll {
        /// Name of the component
        name: String,
    },

    /// Generate individual components
    Gen {
        #[command(subcommand)]
        command: GenCommands,
    },
}

#[derive(Subcommand)]
enum NewCommands {
    /// Create a new project
    Project {
        /// Project name
        name: String,
    },
}

#[derive(Subcommand)]
enum GenCommands {
    /// Generate a service
    Service {
        /// Service name
        name: String,
    },

    /// Generate a usecase
    Usecase {
        /// Usecase name
        name: String,
    },

    /// Generate a repository
    Repository {
        /// Repository name
        name: String,
    },

    /// Generate a data model
    Data {
        /// Data model name
        name: String,
    },

    /// Generate API handler
    Handler {
        /// Handler name
        name: String,
    },

    /// Regenerate Swagger/OpenAPI documentation
    Swagger {
        /// Component name
        name: String,
    },

    /// Generate database adapter(s)
    Adapter {
        /// Component name
        name: String,

        /// Database type: postgres, mysql, mongodb, sqlite, or 'all' for all types
        #[arg(short, long, default_value = "all")]
        db_type: String,
    },

    /// Generate database config
    Config {
        /// Component name (for template variable replacement)
        name: String,
    },

    /// Generate repository factory
    Factory {
        /// Component name
        name: String,
    },

    /// Generate usage examples and documentation
    Example {
        /// Component name
        name: String,
    },

    /// Generate unit tests for service layer
    Test {
        /// Component name
        name: String,
    },

    /// Generate integration tests
    #[command(name = "integration-test")]
    IntegrationTest {
        /// Component name
        name: String,
    },

    /// Generate database migration(s)
    Migration {
        /// Component name
        name: String,

        /// Database type: postgres, mysql, sqlite, mongodb, or 'all' for all types
        #[arg(short, long, default_value = "all")]
        db_type: String,
    },
}

fn main() {
    let cli = Cli::parse();

    let mut ctx = Context {
        dry_run: cli.dry_run,
        force: cli.force,
        is_new_all: false,
    };

    match cli.command {
        Commands::New { command } => match command {
            NewCommands::Project { name } => {
                generator::project::generate(&ctx, &name);
            }
        },

        Commands::GenAll { name } => {
            ctx.is_new_all = true;  // Set flag for gen-all
            generate_all(&ctx, &name);
        }

        Commands::Gen { command } => match command {
            GenCommands::Service { name } => dispatch(GenKind::Service, &ctx, &name),

            GenCommands::Usecase { name } => dispatch(GenKind::Usecase, &ctx, &name),

            GenCommands::Repository { name } => dispatch(GenKind::Repository, &ctx, &name),

            GenCommands::Data { name } => dispatch(GenKind::Data, &ctx, &name),

            GenCommands::Handler { name } => dispatch(GenKind::Handler, &ctx, &name),

            GenCommands::Swagger { name } => {
                // Force regenerate handler to update Swagger docs
                let force_ctx = Context {
                    dry_run: ctx.dry_run,
                    force: true,  // Always force for swagger regeneration
                    is_new_all: ctx.is_new_all,
                };
                dispatch(GenKind::Handler, &force_ctx, &name);
            }

            GenCommands::Adapter { name, db_type } => {
                if db_type.to_lowercase() == "all" {
                    dispatch(GenKind::AdapterAll, &ctx, &name);
                } else {
                    dispatch(GenKind::Adapter(db_type), &ctx, &name);
                }
            }

            GenCommands::Config { name } => dispatch(GenKind::Config, &ctx, &name),

            GenCommands::Factory { name } => dispatch(GenKind::Factory, &ctx, &name),

            GenCommands::Example { name } => dispatch(GenKind::Example, &ctx, &name),

            GenCommands::Test { name } => dispatch(GenKind::Test, &ctx, &name),

            GenCommands::IntegrationTest { name } => dispatch(GenKind::IntegrationTest, &ctx, &name),

            GenCommands::Migration { name, db_type } => {
                if db_type.to_lowercase() == "all" {
                    dispatch(GenKind::MigrationAll, &ctx, &name);
                } else {
                    dispatch(GenKind::Migration(db_type), &ctx, &name);
                }
            }
        },
    }
}

