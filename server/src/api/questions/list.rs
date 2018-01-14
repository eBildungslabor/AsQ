use std::sync::{Arc, Mutex};

use iron::prelude::*;
use iron::Handler;
use iron::headers::ContentType;
use iron::status;
use serde_json as json;

use models::{Question, Resource};
use models::question::{AllQuestionsQuery, /*FindQuestionQuery,*/ QuestionRecord};


pub struct ListH {
    persistent_medium: Arc<Mutex<QuestionRecord>>,
}

#[derive(Serialize)]
struct ListQuestionsResponse {
    pub error: Option<String>,
    pub questions: Vec<Question>,
}

impl ListH {
    pub fn new(record: Arc<Mutex<QuestionRecord>>) -> Self {
        ListH {
            persistent_medium: record,
        }
    }
}

impl Handler for ListH {
    fn handle(&self, _: &mut Request) -> IronResult<Response> {
        let database = self.persistent_medium.lock().unwrap();
        let questions = database
            .all(AllQuestionsQuery {
                presentation: "TODO".to_string(),
            })
            .unwrap();
        let response = ListQuestionsResponse {
            error: None,
            questions: questions,
        };
        let body = json::to_string(&response).unwrap();
        Ok(Response::with((
            ContentType::json().0,
            status::Ok,
            body,
        )))
    }
}
