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
