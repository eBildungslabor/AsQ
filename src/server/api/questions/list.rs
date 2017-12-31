use rocket_contrib::json::Json;

use models::question::Question;


/// The response to a request for a list of questions.
#[derive(Debug, Serialize, Deserialize)]
pub struct QuestionList {
    pub error: Option<String>,
    pub questions: Vec<Question>,
}

/// Get a list of questions asked during a given presentation.
#[get("/api/questions?<presentation>")]
pub fn questions_list(presentation: &str) -> Json<QuestionList> {
    let response = QuestionList {
        error: None,
        questions: vec![
            Question {
                id:           "A0142sfudgSDgj34".to_string(),
                presentation: "ABCDEF0123456789".to_string(),
                //time_asked:    Instant::now(),
                question_text: "How is a monad related to a burrito, in 280 charcters or less?".to_string(),
                nods:          9001,
                answered:      true,
            },
            Question {
                id:           "A014345ifgSDgj34".to_string(),
                presentation: "DEFABC0123456789".to_string(),
                //time_asked:    Instant::now(),
                question_text: "What is the type of Clojure's 'mapping' transducer?".to_string(),
                nods:          1,
                answered:      false,
            },
            Question {
                id:           "Sh59sfG23dfHa2yt".to_string(),
                presentation: "000FED0123456789".to_string(),
                //time_asked:    Instant::now(),
                question_text: "How do I learn Haskell in less than a year?".to_string(),
                nods:          42,
                answered:      true,
            },
            Question {
                id:           "SDF43rfHDJ232Dsd".to_string(),
                presentation: "CABBAC0123456789".to_string(),
                //time_asked:    Instant::now(),
                question_text: "Should I learn Rust?".to_string(),
                nods:          101,
                answered:      true,
            },
        ],
    };
    Json(response)
}