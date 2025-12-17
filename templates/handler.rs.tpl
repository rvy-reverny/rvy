use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::{IntoResponse, Json},
    routing::{delete, get, post, put},
    Router,
};
use serde_json::json;
use std::sync::Arc;

use crate::service::{{name}}_service::{{Name}}Service;
use crate::data::{{name}}_data::{{Name}}Data;

pub struct {{Name}}Handler {
    service: Arc<{{Name}}Service>,
}

impl {{Name}}Handler {
    pub fn new(service: Arc<{{Name}}Service>) -> Self {
        Self { service }
    }

    pub fn routes(service: Arc<{{Name}}Service>) -> Router {
        Router::new()
            .route("/{{name}}s", get(Self::get_all))
            .route("/{{name}}s/:id", get(Self::get_by_id))
            .route("/{{name}}s", post(Self::create))
            .route("/{{name}}s/:id", put(Self::update))
            .route("/{{name}}s/:id", delete(Self::delete))
            .with_state(service)
    }

    async fn get_all(
        State(service): State<Arc<{{Name}}Service>>,
    ) -> Result<Json<Vec<{{Name}}Data>>, (StatusCode, String)> {
        match service.get_all().await {
            Ok(items) => Ok(Json(items)),
            Err(e) => Err((StatusCode::INTERNAL_SERVER_ERROR, e.to_string())),
        }
    }

    async fn get_by_id(
        State(service): State<Arc<{{Name}}Service>>,
        Path(id): Path<i64>,
    ) -> Result<Json<{{Name}}Data>, (StatusCode, String)> {
        match service.get_by_id(id).await {
            Ok(item) => Ok(Json(item)),
            Err(e) => Err((StatusCode::NOT_FOUND, e.to_string())),
        }
    }

    async fn create(
        State(service): State<Arc<{{Name}}Service>>,
        Json(data): Json<{{Name}}Data>,
    ) -> Result<(StatusCode, Json<{{Name}}Data>), (StatusCode, String)> {
        match service.create(data).await {
            Ok(item) => Ok((StatusCode::CREATED, Json(item))),
            Err(e) => Err((StatusCode::BAD_REQUEST, e.to_string())),
        }
    }

    async fn update(
        State(service): State<Arc<{{Name}}Service>>,
        Path(id): Path<i64>,
        Json(data): Json<{{Name}}Data>,
    ) -> Result<Json<{{Name}}Data>, (StatusCode, String)> {
        match service.update(id, data).await {
            Ok(item) => Ok(Json(item)),
            Err(e) => Err((StatusCode::BAD_REQUEST, e.to_string())),
        }
    }

    async fn delete(
        State(service): State<Arc<{{Name}}Service>>,
        Path(id): Path<i64>,
    ) -> Result<StatusCode, (StatusCode, String)> {
        match service.delete(id).await {
            Ok(_) => Ok(StatusCode::NO_CONTENT),
            Err(e) => Err((StatusCode::NOT_FOUND, e.to_string())),
        }
    }
}
