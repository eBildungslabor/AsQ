use iron::prelude::*;
use iron::status;
use iron::headers::ContentType;
use serde_json as json;


#[derive(Serialize, Deserialize)]
pub struct Question {
    pub id: String,
    pub presentation: String,
    #[serde(rename = "questionText")]
    pub text: String,
    pub nods: u32,
    pub answered: bool,
    #[serde(rename = "timeAsked")]
    pub asked: String,
}


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
