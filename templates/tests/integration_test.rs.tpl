use axum::{
    body::Body,
    http::{Request, StatusCode},
};
use tower::ServiceExt;
use serde_json::json;
use std::sync::Arc;

mod common;
use common::*;

#[tokio::test]
async fn test_get_all_{{name}}s() {
    let service = Arc::new(create_test_service());
    let app = {{Name}}Handler::routes(service);

    let response = app
        .clone()
        .oneshot(
            Request::builder()
                .uri("/{{name}}s")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
}

#[tokio::test]
async fn test_get_{{name}}_by_id() {
    let service = Arc::new(create_test_service());
    let app = {{Name}}Handler::routes(service);

    let response = app
        .clone()
        .oneshot(
            Request::builder()
                .uri("/{{name}}s/1")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
}

#[tokio::test]
async fn test_create_{{name}}() {
    let service = Arc::new(create_test_service());
    let app = {{Name}}Handler::routes(service);

    let new_{{name}} = json!({
        "id": 3,
        "name": "Test {{Name}}",
        "created_at": null,
        "updated_at": null
    });

    let response = app
        .clone()
        .oneshot(
            Request::builder()
                .method("POST")
                .uri("/{{name}}s")
                .header("content-type", "application/json")
                .body(Body::from(serde_json::to_string(&new_{{name}}).unwrap()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::CREATED);
}

#[tokio::test]
async fn test_update_{{name}}() {
    let service = Arc::new(create_test_service());
    let app = {{Name}}Handler::routes(service);

    let updated_{{name}} = json!({
        "id": 1,
        "name": "Updated {{Name}}",
        "created_at": null,
        "updated_at": null
    });

    let response = app
        .oneshot(
            Request::builder()
                .method("PUT")
                .uri("/{{name}}s/1")
                .header("content-type", "application/json")
                .body(Body::from(serde_json::to_string(&updated_{{name}}).unwrap()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
}

#[tokio::test]
async fn test_delete_{{name}}() {
    let service = Arc::new(create_test_service());
    let app = {{Name}}Handler::routes(service);

    let response = app
        .clone()
        .oneshot(
            Request::builder()
                .method("DELETE")
                .uri("/{{name}}s/1")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::NO_CONTENT);
}

#[tokio::test]
async fn test_get_{{name}}_not_found() {
    let service = Arc::new(create_test_service());
    let app = {{Name}}Handler::routes(service);

    let response = app
        .clone()
        .oneshot(
            Request::builder()
                .uri("/{{name}}s/999")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}
