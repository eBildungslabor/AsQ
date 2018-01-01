use chrono::prelude::*;
use rocket_contrib::json::Json;

use models::question::Question;


/// The response to a request to update a question.
#[derive(Debug, Serialize)]
pub struct QuestionUpdateResponse {
    pub error: Option<String>,
    pub question: Option<Question>,
}


/// Nod to a question, indicating an audience member's interest in having the question answered.
#[put("/api/questions/<id>/nod")]
pub fn nod(id: String) -> Json<QuestionUpdateResponse> {
    Json(QuestionUpdateResponse{
        error: None,
        question: Some(Question {
            id: id,
            presentation: "somepresentation".to_string(),
            time_asked: Utc::now(),
            question_text: "The question you asked".to_string(),
            nods: 0,
            answered: false,
        }),
    })
}