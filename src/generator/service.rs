use crate::context::Context;
use crate::generator::{render, write_file, update_module_exports};

pub fn generate(ctx: &Context, name: &str) {
    let template = include_str!("../../templates/service.rs.tpl");

    let content = render(template, name);

    let path = format!("src/service/{}_service.rs", name);

    write_file(ctx, &path, &content);
    
    // Update mod.rs
    update_module_exports(ctx, "src/service/mod.rs", &format!("{}_service", name));
}
