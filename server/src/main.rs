extern crate bodyparser;
extern crate chrono;
extern crate iron;
extern crate persistent;
extern crate ring_pwhash as password_hash;
extern crate router;
extern crate rusqlite as sqlite;
extern crate serde;
#[macro_use] extern crate serde_derive;
extern crate serde_json;

pub mod models;
mod api;
#[macro_use] mod capabilities;

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
    let db_authority = capabilities::sqlite::SQLite::new(db_connection);

    /*
    let register_presenter = api::presenters::RegistrationHandler::new(db_authority);

    let mut router = Router::new();
    router.post("/api/presenters", register_presenter, "register_presenter");
    */

    let ask_question = api::questions::ask::AskHandler::new(db_authority.clone());

    let mut router = Router::new();
    router.post("/api/questions/ask", ask_question, "ask_question");

    let mut chain = Chain::new(router);
    chain.link_before(Read::<bodyparser::MaxBodyLength>::one(MAX_BODY_LENGTH));

    Iron::new(chain).http("127.0.0.1:9001").unwrap();
}
