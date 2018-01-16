use chrono::prelude::*;

use models::Id;


#[derive(Debug, Serialize, Deserialize)]
pub struct Presenter {
    #[serde(rename = "emailAddress")]
    pub email_address: Id,
    #[serde(rename = "passwordHash")]
    pub password_hash: String,
    #[serde(rename = "joinDate")]
    pub join_date: DateTime<Utc>,
}
