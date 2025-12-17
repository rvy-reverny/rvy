use crate::context::Context;
use crate::generator::{render, write_file, update_module_exports};

pub fn generate(ctx: &Context, name: &str) {
    let template = include_str!("../../templates/repository.rs.tpl");

    let content = render(template, name);

    let path = format!("src/repository/{}.rs", name);

    write_file(ctx, &path, &content);
    update_module_exports(ctx, "src/repository/mod.rs", name);
}
