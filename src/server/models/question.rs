use chrono::prelude::*;


/// Information about a question asked during a presentation.
#[derive(Debug, Serialize, Deserialize)]
pub struct Question {
    pub id: String,
    pub presentation: String,
    #[serde(rename="timeAsked")]
    pub time_asked: DateTime<Utc>,
    #[serde(rename="questionText")]
    pub question_text: String,
    pub nods: u32,
    pub answered: bool,
}
