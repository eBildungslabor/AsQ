use iron::prelude::*;
use iron::headers::ContentType;
use iron::status;
use serde_json as json;
use api::questions::Question;

pub fn list(_: &mut Request) -> IronResult<Response> {
    let body = json::to_string(&vec![
        Question {
            id: "abc123".to_string(),
            presentation: "123def".to_string(),
            text: "First question".to_string(),
            nods: 1,
            answered: false,
            asked: "Recently".to_string(),
        },
    ]).unwrap();
    Ok(Response::with((
        ContentType::json().0,
        status::Ok,
        body,
    )))
}
