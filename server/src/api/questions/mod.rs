pub mod list;
pub mod ask;
pub mod nod;

pub use self::list::list;
pub use self::ask::ask;
pub use self::nod::nod;


#[derive(Serialize, Deserialize)]
pub struct Question {
    pub id: String,
    pub presentation: String,
    #[serde(rename = "questionText")]
    pub text: String,
    pub nods: u32,
    pub answered: bool,
    #[serde(rename = "timeAsked")]
    pub asked: String,
}
