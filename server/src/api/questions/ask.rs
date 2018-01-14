use bodyparser;
use iron::prelude::*;
use iron::Handler;
use iron::headers::ContentType;
use iron::status;
use serde_json as json;

use api::questions::Question;


pub struct AskH {
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
    pub fn new() -> Self {
        AskH {
        }
    }
}

impl Handler for AskH {
    fn handle(&self, req: &mut Request) -> IronResult<Response> {
        let request = req.get::<bodyparser::Struct<AskQuestionRequest>>().unwrap().unwrap();
        let body = json::to_string(&AskQuestionResponse {
            error: None,
            question: Some(Question {
                id: "newquestion".to_string(),
                presentation: request.presentation,
                text: request.question,
                nods: 0,
                answered: false,
                asked: "Just now".to_string(),
            }),
        }).unwrap();
        Ok(Response::with((
            ContentType::json().0,
            status::Ok,
            body,
        )))
    }
}

