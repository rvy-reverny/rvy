#[derive(Debug, Clone)]
pub struct Context {
    pub dry_run: bool,
    pub force: bool,
    pub is_new_all: bool,  // Flag to indicate if called from new-all command
}
