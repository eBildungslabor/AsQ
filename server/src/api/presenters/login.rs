use std::error::Error;

use iron::prelude::*;
use iron::Handler;
use iron::status;

use capabilities::{Capability, Save, Search};
use models::{Id, Presenter, Session};


/// Handles presenter authentication from the landing page.
pub struct LoginHandler<DB> {
    database: DB,
}

#[derive(Clone, Debug, Deserialize)]
struct LoginRequest {
    #[serde(rename = "emailAddress")]
    pub email_address: Id,
    pub password: String,
}

#[derive(Debug, Serialize)]
struct LoginResponse {
    pub error: Option<String>,
    #[serde(rename = "sessionToken")]
    pub session_token: Option<Id>,
}

impl<DB> LoginHandler<DB> {
    pub fn new(db: DB) -> Self {
        LoginHandler {
            database: db,
        }
    }
}

impl<DB> Handler for LoginHandler<DB>
    where DB: 'static + Sync + Send
        + Capability<Search<Presenter>, Data = Presenter, Error = String>
        + Capability<Save<Session>, Data = Session, Error = String>
{
    fn handle(&self, request: &mut Request) -> IronResult<Response> {
        let request_data = decode_body_or_write_error!(
            request,
            LoginRequest,
            |_: Option<&Error>| LoginResponse {
                error: Some("Missing or invalid request data.".to_string()),
                session_token: None,
            });
        let db_result = try_do!({
            let to_find = Presenter::search_parameter(request_data.email_address);
            let presenter = self.database.perform(Search(to_find))?;
            if presenter.password_matches(&request_data.password) {
                let session = Session::new(presenter);
                self.database.perform(Save(session))
            } else {
                Err("Invalid credentials".to_string())
            }
        });
        match db_result {
            Ok(session) => json_response!(status::Ok, LoginResponse {
                error: None,
                session_token: Some(session.token),
            }),
            _ => json_response!(status::BadRequest, LoginResponse {
                error: Some("Invalid credentials.".to_string()),
                session_token: None,
            }),
        }
    }
}
