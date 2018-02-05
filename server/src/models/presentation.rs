use chrono::prelude::*;

use models::Id;


#[derive(Debug, Serialize, Deserialize)]
pub struct Presentation {
    pub id: Id,
    pub creator: Id,
    pub title: String,
    #[serde(rename = "isOpenToQuestions")]
    pub is_open_to_questions: bool,
    #[serde(rename = "creationDate")]
    pub creation_date: DateTime<Utc>,
}

impl Presentation {
    /// Create an instance of `Presentation` to pass to a search operation.
    pub fn search_parameter(id: Id) -> Self {
        Presentation {
            id: id,
            creator: Id(String::new()),
            title: String::new(),
            is_open_to_questions: true,
            creation_date: Utc::now(),
        }
    }
}
