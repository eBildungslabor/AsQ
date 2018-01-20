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
    where DB: 'static + Sync + Send + Capability<Save<Presenter>, Data = Presenter>
{
    fn handle(&self, request: &mut Request) -> IronResult<Response> {
        println!("Got a request");
        let req_data = match request.get::<bodyparser::Struct<RegistrationRequest>>() {
            Ok(Some(request_data)) => request_data,
            _ => {
                let body = json::to_string(&RegistrationResponse {
                    error: Some("Missing or invalid request data.".to_string()),
                }).unwrap();
                return Ok(Response::with((
                    status::BadRequest,
                    body,
                 )));
            },
        };
        println!("Parsed request data");
        let presenter = Presenter::new(req_data.email_address, req_data.password);
        println!("Created presenter {:?}", presenter);
        match self.database.perform(Save(presenter)) {
            Ok(presenter) => {
                println!("Saved presenter");
                let body = json::to_string(&RegistrationResponse {
                    error: None,
                }).unwrap();
                Ok(Response::with((
                    status::Ok,
                    body,
                )))
            },
            Err(err_msg) => {
                println!("Encountered an error");
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
