use std::error::Error;

use bodyparser;
use iron::headers::ContentType;
use iron::middleware::Handler;
use iron::prelude::*;
use iron::status;
use serde_json as json;

use capabilities::{Capability, Save};
use models::{Id, Question};


/// Handles requests to have a new question asked during a presentation.
pub struct AskHandler<DB> {
    database: DB,
}

#[derive(Clone, Debug, Deserialize)]
struct AskRequest {
    #[serde(rename = "presentation")]
    pub presentation_id: Id,
    pub question: String,
}

#[derive(Debug, Serialize)]
struct AskResponse {
    pub error: Option<String>,
    pub question: Option<Question>,
}

impl<DB> AskHandler<DB> {
    pub fn new(db: DB) -> Self {
        AskHandler {
            database: db,
        }
    }
}

impl<DB> Handler for AskHandler<DB>
    where DB: 'static + Sync + Send + Capability<Save<Question>, Data = Question>
{
    fn handle(&self, request: &mut Request) -> IronResult<Response> {
        let req_data = decode_or_write_error!(request, AskRequest, |_: Option<&Error>| AskResponse {
            error: Some("Missing or invalid request data.".to_string()),
            question: None,
        });
        let new_question = Question::new(req_data.presentation_id, req_data.question);
        match self.database.perform(Save(new_question)) {
            Ok(saved) => json_response!(status::Ok, AskResponse {
                error: None,
                question: Some(saved),
            }),
            _ => json_response!(status::InternalServerError, AskResponse {
                error: Some("Failed to save question. Try again later.".to_string()),
                question: None,
            }),
        }
    }
}
