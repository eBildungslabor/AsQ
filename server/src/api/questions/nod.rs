use std::error::Error;

use bodyparser;
use iron::headers::ContentType;
use iron::middleware::Handler;
use iron::prelude::*;
use iron::status;
use serde_json as json;

use capabilities::{Capability, Search, Update};
use models::{Id, Question};


/// Handles requests to have a question nodded to.
pub struct NodHandler<DB> {
    database: DB
}

#[derive(Clone, Debug, Deserialize)]
struct NodRequest {
    #[serde(rename = "question")]
    pub question_id: Id,
}

#[derive(Debug, Serialize)]
struct NodResponse {
    pub error: Option<String>,
}

impl<DB> NodHandler<DB> {
    pub fn new(db: DB) -> Self {
        NodHandler {
            database: db,
        }
    }
}

impl<DB> Handler for NodHandler<DB>
    where DB: 'static + Sync + Send + Capability<Search<Question>, Data = Question, Error = String> + Capability<Update<Question>, Error = String>
{
    fn handle(&self, request: &mut Request) -> IronResult<Response> {
        let req_data = decode_or_write_error!(request, NodRequest, |_: Option<&Error>| NodResponse {
            error: Some("Missing or invalid request data.".to_string()),
        });
        let db_result = try_do!({
            let mut question = self.database.perform(Search(Question::search_parameter(req_data.question_id)))?;
            question.nods += 1;
            self.database.perform(Update(question))
        });
        match db_result {
            Ok(_) => json_response!(status::Ok, NodResponse { error: None }),
            _     => json_response!(status::BadRequest, NodResponse { error: Some("Invalid question.".to_string())}),
        }
    }
}
