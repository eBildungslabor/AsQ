//use std::time::Instant;

use rocket_contrib::json::Json;

use models::question::Question;


/// The response to a request for a list of questions.
#[derive(Debug, Serialize, Deserialize)]
pub struct QuestionList {
    pub error: Option<String>,
    pub questions: Vec<Question>,
}

/// Get a list of questions asked during a given presentation.
#[get("/questions?<presentation>")]
pub fn questions_list(presentation: &str) -> Json<QuestionList> {
    let response = QuestionList {
        error: None,
        questions: vec![
            Question {
                presentation: "ABCDEF0123456789".to_string(),
                //time_asked:    Instant::now(),
                question_text: "How is a monad related to a burrito, in 280 charcters or less?".to_string(),
                upvotes:       9001,
                answered:      true,
            },
            Question {
                presentation: "DEFABC0123456789".to_string(),
                //time_asked:    Instant::now(),
                question_text: "What is the type of Clojure's 'mapping' transducer?".to_string(),
                upvotes:       1,
                answered:      false,
            },
            Question {
                presentation: "000FED0123456789".to_string(),
                //time_asked:    Instant::now(),
                question_text: "How do I learn Haskell in less than a year?".to_string(),
                upvotes:       42,
                answered:      true,
            },
            Question {
                presentation: "CABBAC0123456789".to_string(),
                //time_asked:    Instant::now(),
                question_text: "Should I learn Rust?".to_string(),
                upvotes:       101,
                answered:      true,
            },
        ],
    };
    Json(response)
}
