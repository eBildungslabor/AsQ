//use std::time;


/// Information about a question asked during a presentation.
#[derive(Debug, Serialize, Deserialize)]
pub struct Question {
    pub presentation: String,
    //#[serde(rename="timeAsked")]
    //pub time_asked: time::Instant,
    #[serde(rename="questionText")]
    pub question_text: String,
    pub nods: u32,
    pub answered: bool,
}
