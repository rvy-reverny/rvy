use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde::Serialize;

/// Custom error type for the application
#[derive(Debug)]
pub enum AppError {
    /// Database errors (SQLx, MongoDB)
    Database(String),
    /// Not found errors
    NotFound(String),
    /// Validation errors
    Validation(String),
    /// Authentication/Authorization errors
    Unauthorized(String),
    /// Internal server errors
    Internal(String),
    /// Bad request errors
    BadRequest(String),
}

impl std::fmt::Display for AppError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AppError::Database(msg) => write!(f, "Database error: {}", msg),
            AppError::NotFound(msg) => write!(f, "Not found: {}", msg),
            AppError::Validation(msg) => write!(f, "Validation error: {}", msg),
            AppError::Unauthorized(msg) => write!(f, "Unauthorized: {}", msg),
            AppError::Internal(msg) => write!(f, "Internal error: {}", msg),
            AppError::BadRequest(msg) => write!(f, "Bad request: {}", msg),
        }
    }
}

impl std::error::Error for AppError {}

/// Error response structure for API responses
#[derive(Serialize)]
pub struct ErrorResponse {
    pub error: String,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub details: Option<String>,
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, error_type, message) = match self {
            AppError::Database(msg) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                "DATABASE_ERROR",
                msg,
            ),
            AppError::NotFound(msg) => (StatusCode::NOT_FOUND, "NOT_FOUND", msg),
            AppError::Validation(msg) => (StatusCode::BAD_REQUEST, "VALIDATION_ERROR", msg),
            AppError::Unauthorized(msg) => (StatusCode::UNAUTHORIZED, "UNAUTHORIZED", msg),
            AppError::Internal(msg) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                "INTERNAL_ERROR",
                msg,
            ),
            AppError::BadRequest(msg) => (StatusCode::BAD_REQUEST, "BAD_REQUEST", msg),
        };

        let body = Json(ErrorResponse {
            error: error_type.to_string(),
            message: message.clone(),
            details: None,
        });

        (status, body).into_response()
    }
}

/// Convert SQLx errors to AppError
impl From<sqlx::Error> for AppError {
    fn from(err: sqlx::Error) -> Self {
        match err {
            sqlx::Error::RowNotFound => AppError::NotFound("Record not found".to_string()),
            sqlx::Error::Database(db_err) => AppError::Database(db_err.to_string()),
            _ => AppError::Database(err.to_string()),
        }
    }
}

/// Convert MongoDB errors to AppError
impl From<mongodb::error::Error> for AppError {
    fn from(err: mongodb::error::Error) -> Self {
        AppError::Database(err.to_string())
    }
}

/// Convert serde_json errors to AppError
impl From<serde_json::Error> for AppError {
    fn from(err: serde_json::Error) -> Self {
        AppError::BadRequest(format!("JSON parsing error: {}", err))
    }
}

/// Convert std::io errors to AppError
impl From<std::io::Error> for AppError {
    fn from(err: std::io::Error) -> Self {
        AppError::Internal(err.to_string())
    }
}

/// Type alias for Results with AppError
pub type Result<T> = std::result::Result<T, AppError>;
