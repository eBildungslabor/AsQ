use chrono::prelude::*;

use models::Id;


#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Question {
    pub id: Id,
    pub presentation: Id,
    pub text: String,
    pub nods: u32,
    pub answered: bool,
    #[serde(rename = "timeAsked")]
    pub ask_date: DateTime<Utc>,
}

impl Question {
    /// Construct a new question being asked during a presentation.
    pub fn new(presentation: Id, question_text: String) -> Self {
        Question {
            id: Id(String::new()),
            presentation: presentation,
            text: question_text,
            nods: 0,
            answered: false,
            ask_date: Utc::now(),
        }
    }

    /// Construct a question with a given ID so the question can be passed to a search operation.
    pub fn search_parameter(id: Id) -> Self {
        Question {
            id: id,
            presentation: Id(String::new()),
            text: String::new(),
            nods: 0,
            answered: false,
            ask_date: Utc::now(),
        }
    }
}
