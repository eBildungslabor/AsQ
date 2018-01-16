extern crate bodyparser;
extern crate iron;
extern crate persistent;
#[macro_use] extern crate serde_derive;
extern crate serde;
extern crate serde_json;
extern crate router;
extern crate rusqlite as sqlite;

pub mod models;
mod api;

use std::sync::{Arc, Mutex};

use iron::prelude::*;
use persistent::Read;
use router::Router;


const MAX_BODY_LENGTH: usize = 10 * 1024 * 1024;
const DATABASE_FILE: &'static str = "asq.db";


fn main() {
    let db_connection = Arc::new(Mutex::new(
        sqlite::Connection::open(DATABASE_FILE).expect("Could not connect to database.")
    ));
    let questions_record = Arc::new(Mutex::new(
        models::question::QuestionRecord::new(db_connection)
    ));

    let list_questions = api::questions::ListH::new(questions_record.clone());
    let ask_question = api::questions::AskH::new(questions_record.clone());
    let nod_to_question = api::questions::NodH::new(questions_record);

    let mut router = Router::new();
    router.get("/api/questions", list_questions, "list_questions");
    router.post("/api/questions", ask_question, "ask_question");
    router.put("/api/questions/:id/nod", nod_to_question, "nod_to_question");

    let mut chain = Chain::new(router);
    chain.link_before(Read::<bodyparser::MaxBodyLength>::one(MAX_BODY_LENGTH));

    Iron::new(chain).http("127.0.0.1:9001").unwrap();
}
