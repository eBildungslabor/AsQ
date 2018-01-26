use std::error::Error;

use bodyparser;
use iron::middleware::Handler;
use iron::prelude::*;
use iron::status;
use serde_json as json;

use capabilities::{Capability, Save};
use models::Presenter;


/// Handles requests to register a new presenter (effectively, a user).
pub struct RegistrationHandler<DB> {
    database: DB,
}

#[derive(Clone, Debug, Deserialize)]
struct RegistrationRequest {
    #[serde(rename = "emailAddress")]
    pub email_address: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
struct RegistrationResponse {
    pub error: Option<String>,
}

impl<DB> RegistrationHandler<DB> {
    pub fn new(db: DB) -> Self {
        RegistrationHandler {
            database: db,
        }
    }
}

impl<DB> Handler for RegistrationHandler<DB>
    where DB: 'static + Sync + Send + Capability<Save<Presenter>>
{
    fn handle(&self, request: &mut Request) -> IronResult<Response> {
        let req_data = decode_body_or_write_error!(request, RegistrationRequest, |_: Option<&Error>| RegistrationResponse {
            error: Some("Missing or invalid request data.".to_string()),
        });
        let presenter = Presenter::new(req_data.email_address, req_data.password);
        match self.database.perform(Save(presenter)) {
            Ok(presenter) => {
                let body = json::to_string(&RegistrationResponse {
                    error: None,
                }).unwrap();
                Ok(Response::with((
                    status::Ok,
                    body,
                )))
            },
            Err(err_msg) => {
                let body = json::to_string(&RegistrationResponse {
                    error: Some("Something went wrong!".to_string()),
                }).unwrap();
                Ok(Response::with((
                    status::InternalServerError,
                    body,
                )))
            }
        }
    }
}
