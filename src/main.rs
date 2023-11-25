use std::net::SocketAddr;

use axum::Router;
use axum::routing::get;
use mini_redis::Result;
use tracing_subscriber;

use application::user_app;

mod application;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let app = Router::new()
        .route("/", get(user_app::root()));


    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    tracing::debug!("listening on {}", addr);
    Ok(axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await?)
}