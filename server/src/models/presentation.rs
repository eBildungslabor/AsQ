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
