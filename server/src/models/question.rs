use chrono::prelude::*;

use models::Id;


#[derive(Debug, Serialize, Deserialize)]
pub struct Question {
    pub id: Id,
    pub presentation: Id,
    pub text: String,
    #[serde(rename = "askDate")]
    pub ask_date: DateTime<Utc>,
}

impl Question {
    pub fn new(presentation: Id, question_text: String) -> Self {
        Question {
            id: Id(String::new()),
            presentation: presentation,
            text: question_text,
            ask_date: Utc::now(),
        }
    }
}
