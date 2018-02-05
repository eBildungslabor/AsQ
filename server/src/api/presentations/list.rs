use iron::prelude::*;
use iron::Handler;
use iron::status;

use capabilities::{Capability, FindAll};
use capabilities::sqlite::PresentationsForPresenter;
use models::{Id, Presentation};


/// Handles requests to get a list of presentations created by a presenter.
pub struct ListHandler<DB> {
    database: DB,
}

#[derive(Clone, Debug, Deserialize)]
struct ListRequest {
    pub presenter: Id,
}

#[derive(Debug, Serialize)]
struct ListResponse {
    pub error: Option<String>,
    pub presentations: Vec<Presentation>,
}

impl<DB> ListHandler<DB> {
    pub fn new(db: DB) -> Self {
        ListHandler {
            database: db,
        }
    }
}

impl<DB> Handler for ListHandler<DB> 
    where DB: 'static + Sync + Send
        + Capability<FindAll<PresentationsForPresenter>, Data = Vec<Presentation>>
{
    fn handle(&self, request: &mut Request) -> IronResult<Response> {
        let input_err = "Missing or invalid request data.".to_string();
        let presenter_id = decode_query_or_write_error!(
            request,
            extract = |query| query
                .get("presenter")
                .and_then(|strings| strings.first())
                .map(|id| Id(id.clone())),
            missing = ListResponse {
                error: Some(input_err),
                presentations: vec![],
            });
        let db_result = self.database.perform(FindAll(PresentationsForPresenter {
            presenter_id: presenter_id,
        }));
        match db_result {
            Ok(presentations) => json_response!(status::Ok, ListResponse {
                error: None,
                presentations: presentations,
            }),
            _ => json_response!(status::BadRequest, ListResponse {
                error: Some("Unknown presenter.".to_string()),
                presentations: vec![],
            }),
        }
    }
}
