use std::sync::{Arc, Mutex};

use bodyparser;
use iron::prelude::*;
use iron::Handler;
use iron::headers::ContentType;
use iron::status;
use serde_json as json;

use models::{Question, Resource};
use models::question::{QuestionRecord};


pub struct AskH {
    persistent_medium: Arc<Mutex<QuestionRecord>>
}

#[derive(Clone, Deserialize)]
struct AskQuestionRequest {
    pub presentation: String,
    pub question: String,
}

#[derive(Serialize)]
struct AskQuestionResponse {
    pub error: Option<String>,
    pub question: Option<Question>,
}

impl AskH {
    pub fn new(record: Arc<Mutex<QuestionRecord>>) -> Self {
        AskH {
            persistent_medium: record,
        }
    }
}

impl Handler for AskH {
    fn handle(&self, req: &mut Request) -> IronResult<Response> {
        let request = match req.get::<bodyparser::Struct<AskQuestionRequest>>() {
            Ok(Some(request)) => request,
            _ => {
                let body = json::to_string(&AskQuestionResponse {
                    error: Some("invalid request".to_string()),
                    question: None,
                })
                .unwrap();
                return Ok(Response::with((
                    ContentType::json().0,
                    status::BadRequest,
                    body,
                )));
            }
        };
        let database = self.persistent_medium.lock().unwrap();
        let mut question = Question {
            id: "newquestion".to_string(),
            presentation: request.presentation,
            text: request.question,
            nods: 0,
            answered: false,
            asked: "Just now".to_string(),
        };
        let (status_code, error) = match database.save(&mut question) {
            Ok(_) => (status::Ok, None),
            _     => (status::InternalServerError, Some("database communication error".to_string())),
        };
        let question = if error.is_some() { None } else { Some(question) };
        let body = json::to_string(&AskQuestionResponse {
            error: error,
            question: question,
        })
        .unwrap();
        Ok(Response::with((
            ContentType::json().0,
            status_code,
            body,
        )))
    }
}
