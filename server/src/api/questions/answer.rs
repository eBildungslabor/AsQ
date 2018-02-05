use std::error::Error;

use iron::Handler;
use iron::prelude::*;
use iron::status;

use capabilities::{Capability, Save, Search};
use models::{Id, Answer, Presentation, Question, Session};


/// Handles requests to post an answer to a question.
pub struct AnswerHandler<DB> {
    database: DB,
}

#[derive(Clone, Debug, Deserialize)]
struct AnswerRequest {
    #[serde(rename = "sessionToken")]
    pub session_token: Id,
    #[serde(rename = "question")]
    pub question_id: Id,
    pub text: String,
}

#[derive(Debug, Serialize)]
struct AnswerResponse {
    pub error: Option<String>,
    pub answer: Option<Answer>,
}

impl<DB> AnswerHandler<DB> {
    pub fn new(db: DB) -> Self {
        AnswerHandler {
            database: db,
        }
    }
}

impl<DB> Handler for AnswerHandler<DB>
    where DB: 'static + Sync + Send
        + Capability<Search<Question>, Data = Question, Error = String>
        + Capability<Search<Presentation>, Data = Presentation, Error = String>
        + Capability<Search<Session>, Data = Session, Error = String>
        + Capability<Save<Answer>, Data = Answer, Error = String>
{
    fn handle(&self, request: &mut Request) -> IronResult<Response> {
        let request_data = decode_body_or_write_error!(request, AnswerRequest, |_: Option<&Error>| AnswerResponse {
            error: Some("Missing or invalid request data.".to_string()),
            answer: None,
        });
        let db_result = try_do!({
            let question = Question::search_parameter(request_data.question_id);
            let question = self.database.perform(Search(question))?;
            let presentation = Presentation::search_parameter(question.presentation);
            let presentation = self.database.perform(Search(presentation))?;
            let session = Session::search_parameter(request_data.session_token);
            let session = self.database.perform(Search(session))?;
            if presentation.creator == session.owner {
                let answer = Answer::new(session.owner, question.id, request_data.text);
                self.database.perform(Save(answer))
            } else {
                Err("You are not allowed to do that!".to_string())
            }
        });
        match db_result {
            Ok(answer) => json_response!(status::Ok, AnswerResponse {
                error: None,
                answer: Some(answer),
            }),
            Err(err)   => json_response!(status::BadRequest, AnswerResponse {
                error: Some(err),
                answer: None,
            }),
        }
    }
}
