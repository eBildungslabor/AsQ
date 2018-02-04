use std::error::Error;

use iron::prelude::*;
use iron::Handler;
use iron::status;

use capabilities::{Capability, Save};
use models::{Id, Presenter, Session};


/// Handles presenter registration from the landing page.
pub struct RegistrationHandler<DB> {
    database: DB,
}

#[derive(Clone, Debug, Deserialize)]
struct RegisterRequest {
    #[serde(rename = "emailAddress")]
    pub email_address: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
struct RegisterResponse {
    pub error: Option<String>,
    #[serde(rename = "sessionToken")]
    pub session_token: Option<Id>,
}

impl<DB> RegistrationHandler<DB> {
    pub fn new(db: DB) -> Self {
        RegistrationHandler {
            database: db,
        }
    }
}

impl<DB> Handler for RegistrationHandler<DB>
    where DB: 'static + Sync + Send
        + Capability<Save<Presenter>, Data = Presenter, Error = String>
        + Capability<Save<Session>, Data = Session, Error = String>
{
    fn handle(&self, request: &mut Request) -> IronResult<Response> {
        let request_data = decode_body_or_write_error!(
            request,
            RegisterRequest,
            |_: Option<&Error>| RegisterResponse {
                error: Some("Missing or invalid request data.".to_string()),
                session_token: None,
            });
        let new_presenter = Presenter::new(request_data.email_address, request_data.password);
        let db_result = try_do!({
            let saved_presenter = self.database.perform(Save(new_presenter))?;
            let session = Session::new(saved_presenter);
            self.database.perform(Save(session))
        });
        match db_result {
            Ok(session) => json_response!(status::Ok, RegisterResponse {
                error: None,
                session_token: Some(session.token),
            }),
            _ => json_response!(status::BadRequest, RegisterResponse {
                error: Some("Email address taken.".to_string()),
                session_token: None,
            }),
        }
    }
}
