use std::sync::{Arc, Mutex};

use sqlite::Connection;

use models::{Resource, ModelError};


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

/// A query type used to load a single, specific Question from a persistence medium.
pub struct FindQuestionQuery {
    pub id: String,
}

/// A query type used to find all of the questions asked during a given presentation.
pub struct AllQuestionsQuery {
    pub presentation: String,
}

/// Implements `Recordable` to handle the persistence of Questions.
pub struct QuestionRecord {
    db_connection: Arc<Mutex<Connection>>,
}

impl QuestionRecord {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        QuestionRecord {
            db_connection: conn,
        }
    }
}

impl Resource<AllQuestionsQuery, FindQuestionQuery> for QuestionRecord {
    type Model = Question;

    fn save(&self, model: Question) -> Result<Question, ModelError> {
        Ok(model)
    }

    fn load(&self, query: FindQuestionQuery) -> Result<Question, ModelError> {
        Ok(Question {
            id: query.id,
            presentation: "loadedpresentation".to_string(),
            text: "whatever the question was".to_string(),
            nods: 9,
            answered: false,
            asked: "Three days ago".to_string(),
        })
    }

    fn all(&self, _query: AllQuestionsQuery) -> Result<Vec<Question>, ModelError> {
        Ok(vec![])
    }

    fn update(&self, _model: &Question) -> Result<(), ModelError> {
        Ok(())
    }
}
