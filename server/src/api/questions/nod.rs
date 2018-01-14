use std::sync::{Arc, Mutex};

use iron::prelude::*;
use iron::Handler;
use iron::headers::ContentType;
use iron::status;
use router::Router;
use serde_json as json;

use models::Question;
use models::question::{QuestionRecord};


pub struct NodH {
    persistent_medium: Arc<Mutex<QuestionRecord>>,
}

#[derive(Serialize)]
struct NodToQuestionResponse {
    pub error: Option<String>,
    pub question: Option<Question>,
}

impl NodH {
    pub fn new(record: Arc<Mutex<QuestionRecord>>) -> Self {
        NodH {
            persistent_medium: record,
        }
    }
}

impl Handler for NodH {
    fn handle(&self, req: &mut Request) -> IronResult<Response> {
        let id = req.extensions
            .get::<Router>()
            .unwrap()
            .find("id")
            .unwrap();
        let body = json::to_string(&NodToQuestionResponse {
            error: None,
            question: Some(Question {
                id: id.to_owned(),
                presentation: "somepresentation".to_string(),
                text: "whatever the text was".to_string(),
                nods: 100,
                answered: true,
                asked: "Some time ago".to_string(),
            }),
        }).unwrap();
        Ok(Response::with((
            ContentType::json().0,
            status::Ok,
            body,
        )))
    }
}

