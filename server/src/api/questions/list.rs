use iron::Handler;
use iron::prelude::*;
use iron::status;

use capabilities::{Capability, FindAll};
use capabilities::sqlite::QuestionsForPresentation;
use models::{Id, Question};


/// Handles requests to list questions asked during a presentation.
pub struct ListHandler<DB> {
    database: DB,
}

#[derive(Clone, Debug, Deserialize)]
struct ListRequest {
    #[serde(rename = "presentation")]
    pub presentation_id: Id,
}

#[derive(Debug, Serialize)]
struct ListResponse {
    pub error: Option<String>,
    pub questions: Vec<Question>,
}

impl<DB> ListHandler<DB> {
    pub fn new(db: DB) -> Self {
        ListHandler {
            database: db,
        }
    }
}

impl<DB> Handler for ListHandler<DB>
    where DB: 'static + Sync + Send + Capability<FindAll<QuestionsForPresentation>, Data = Vec<Question>>
{
    fn handle(&self, request: &mut Request) -> IronResult<Response> {
        let input_err = "Missing or invalid request data.".to_string();
        let presentation_id = decode_query_or_write_error!(
            request,
            extract = |query| query
                .get("presentation")
                .and_then(|strings| strings.first())
                .map(|id| Id(id.clone())),
            missing = ListResponse {
                error: Some(input_err),
                questions: vec![],
            }
        );
        let db_result = self.database.perform(FindAll(QuestionsForPresentation {
            presentation_id: presentation_id,
        }));
        match db_result {
            Ok(questions) => json_response!(status::Ok, ListResponse {
                error: None,
                questions: questions,
            }),
            _ => json_response!(status::BadRequest, ListResponse {
                error: Some("Invalid presentation.".to_string()),
                questions: vec![],
            }),
        }
    }
}
