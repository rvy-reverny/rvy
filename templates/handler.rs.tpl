use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::{IntoResponse, Json},
    routing::{delete, get, post, put},
    Router,
};
use serde_json::json;
use std::sync::Arc;
use utoipa::OpenApi;

use crate::service::{{name}}_service::{{Name}}Service;
use crate::data::{{name}}_data::{{Name}}Data;

// NOTE: This file contains business logic and OpenAPI documentation.
// If you modify the data model, you may need to regenerate this file with:
//   rvy gen handler {{name}} --force
// WARNING: This will overwrite any custom changes you've made!

/// OpenAPI documentation for {{Name}} endpoints
#[derive(OpenApi)]
#[openapi(
    paths(
        get_all_{{name}}s,
        get_{{name}}_by_id,
        create_{{name}},
        update_{{name}},
        delete_{{name}}
    ),
    components(schemas({{Name}}Data)),
    tags(
        (name = "{{name}}", description = "{{Name}} management endpoints")
    ),
    modifiers(&SecurityAddon)
)]
pub struct {{Name}}ApiDoc;

/// Add Bearer token authentication to OpenAPI spec
struct SecurityAddon;

impl utoipa::Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        use utoipa::openapi::security::{HttpAuthScheme, HttpBuilder, SecurityScheme};
        
        if let Some(components) = openapi.components.as_mut() {
            components.add_security_scheme(
                "bearer_auth",
                SecurityScheme::Http(
                    HttpBuilder::new()
                        .scheme(HttpAuthScheme::Bearer)
                        .bearer_format("JWT")
                        .build()
                ),
            );
        }
    }
}

pub struct {{Name}}Handler {
    service: Arc<{{Name}}Service>,
}

impl {{Name}}Handler {
    pub fn new(service: Arc<{{Name}}Service>) -> Self {
        Self { service }
    }

    pub fn routes(service: Arc<{{Name}}Service>) -> Router {
        Router::new()
            .route("/{{name}}s", get(get_all_{{name}}s))
            .route("/{{name}}s/:id", get(get_{{name}}_by_id))
            .route("/{{name}}s", post(create_{{name}}))
            .route("/{{name}}s/:id", put(update_{{name}}))
            .route("/{{name}}s/:id", delete(delete_{{name}}))
            .with_state(service)
    }
}

#[utoipa::path(
    get,
    path = "/{{name}}s",
    responses(
        (status = 200, description = "List all {{name}}s", body = [{{Name}}Data])
    ),
    security(
        ("bearer_auth" = [])
    )
)]
async fn get_all_{{name}}s(
    State(service): State<Arc<{{Name}}Service>>,
) -> Result<Json<Vec<{{Name}}Data>>, (StatusCode, String)> {
    match service.get_all().await {
        Ok(items) => Ok(Json(items)),
        Err(e) => Err((StatusCode::INTERNAL_SERVER_ERROR, e.to_string())),
    }
}

#[utoipa::path(
    get,
    path = "/{{name}}s/{id}",
    responses(
        (status = 200, description = "Get {{name}} by ID", body = {{Name}}Data),
        (status = 404, description = "{{Name}} not found")
    ),
    params(
        ("id" = i64, Path, description = "{{Name}} ID")
    ),
    security(
        ("bearer_auth" = [])
    )
)]
async fn get_{{name}}_by_id(
    State(service): State<Arc<{{Name}}Service>>,
    Path(id): Path<i64>,
) -> Result<Json<{{Name}}Data>, (StatusCode, String)> {
    match service.get_by_id(id).await {
        Ok(item) => Ok(Json(item)),
        Err(e) => Err((StatusCode::NOT_FOUND, e.to_string())),
    }
}

#[utoipa::path(
    post,
    path = "/{{name}}s",
    request_body = {{Name}}Data,
    responses(
        (status = 201, description = "{{Name}} created successfully", body = {{Name}}Data),
        (status = 400, description = "Invalid input")
    ),
    security(
        ("bearer_auth" = [])
    )
)]
async fn create_{{name}}(
    State(service): State<Arc<{{Name}}Service>>,
    Json(data): Json<{{Name}}Data>,
) -> Result<(StatusCode, Json<{{Name}}Data>), (StatusCode, String)> {
    match service.create(data).await {
        Ok(item) => Ok((StatusCode::CREATED, Json(item))),
        Err(e) => Err((StatusCode::BAD_REQUEST, e.to_string())),
    }
}

#[utoipa::path(
    put,
    path = "/{{name}}s/{id}",
    request_body = {{Name}}Data,
    responses(
        (status = 200, description = "{{Name}} updated successfully", body = {{Name}}Data),
        (status = 400, description = "Invalid input"),
        (status = 404, description = "{{Name}} not found")
    ),
    params(
        ("id" = i64, Path, description = "{{Name}} ID")
    ),
    security(
        ("bearer_auth" = [])
    )
)]
async fn update_{{name}}(
    State(service): State<Arc<{{Name}}Service>>,
    Path(id): Path<i64>,
    Json(data): Json<{{Name}}Data>,
) -> Result<Json<{{Name}}Data>, (StatusCode, String)> {
    match service.update(id, data).await {
        Ok(item) => Ok(Json(item)),
        Err(e) => Err((StatusCode::BAD_REQUEST, e.to_string())),
    }
}

#[utoipa::path(
    delete,
    path = "/{{name}}s/{id}",
    responses(
        (status = 204, description = "{{Name}} deleted successfully"),
        (status = 404, description = "{{Name}} not found")
    ),
    params(
        ("id" = i64, Path, description = "{{Name}} ID")
    ),
    security(
        ("bearer_auth" = [])
    )
)]
async fn delete_{{name}}(
    State(service): State<Arc<{{Name}}Service>>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    match service.delete(id).await {
        Ok(_) => Ok(StatusCode::NO_CONTENT),
        Err(e) => Err((StatusCode::NOT_FOUND, e.to_string())),
    }
}

