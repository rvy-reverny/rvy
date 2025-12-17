use crate::context::Context;
use crate::generator::{render, write_file};

pub fn generate(ctx: &Context, name: &str) {
    let template = include_str!("../../templates/handler.rs.tpl");

    let content = render(template, name);

    let path = format!("src/handler/{}_handler.rs", name);

    write_file(ctx, &path, &content);
}
