use chrono::prelude::*;

use models::Id;


#[derive(Debug, Serialize, Deserialize)]
pub struct Answer {
    pub id: Id,
    pub author: Id,
    pub question: Id,
    #[serde(rename = "writtenDate")]
    pub written_date: DateTime<Utc>,
    pub text: String,
}

impl Answer {
    pub fn new(author: Id, question: Id, text: String) -> Self {
        Answer {
            id: Id(String::new()),
            author: author,
            question: question,
            written_date: Utc::now(),
            text: text,
        }
    }
}
