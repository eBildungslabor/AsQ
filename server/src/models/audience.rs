use models::Id;


#[derive(Debug, Serialize, Deserialize)]
pub struct Audience {
    pub id: Id,
    #[serde(rename = "submissionToken")]
    pub submission_token: String,
}
