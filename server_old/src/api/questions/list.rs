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
        let fetch_result = database.all(AllQuestionsQuery {
            presentation: "TODO".to_string(),
        });
        let (status_code, error, questions) = match fetch_result {
            Ok(questions) => (status::Ok, None, questions),
            Err(_)        => (status::InternalServerError,
                              Some("database communication error".to_string()),
                              vec![]),
        };
        let response = ListQuestionsResponse {
            error: error,
            questions: questions,
        };
        let body = json::to_string(&response).unwrap();
        Ok(Response::with((
            ContentType::json().0,
            status_code,
            body,
        )))
    }
}
