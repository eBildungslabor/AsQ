use rocket_contrib::json::Json;

use models::question::Question;


/// The data expected to be present in a request to have a question asked.
#[derive(Debug, Deserialize)]
pub struct QuestionAsked {
    pub presentation: String,
    pub question: String,
}

/// The response to a request to have a question asked.
#[derive(Debug, Serialize)]
pub struct QuestionAskedResponse {
    pub error: Option<String>,
    pub question: Option<Question>,
}

/// Ask a question during a presentation.
#[post("/api/questions", data = "<question>")]
pub fn ask(question: Json<QuestionAsked>) -> Json<QuestionAskedResponse> {
    Json(QuestionAskedResponse{
        error: Some("Oh no I blew up!".to_string()),
        question: None,
        /*
        error: None,
        question: Some(Question {
            id: "newquestionid".to_string(),
            presentation: "somepresentation".to_string(),
            // time_asked: Instant::now(),
            question_text: "The question you asked".to_string(),
            nods: 0,
            answered: false,
        }),
        */
    })
}