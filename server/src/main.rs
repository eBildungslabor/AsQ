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
extern crate urlencoded;
extern crate staticfile;
extern crate mount;
extern crate rand;
extern crate base64;

pub mod models;
mod api;
#[macro_use] mod capabilities;

use std::sync::{Arc, Mutex};
use std::path::Path;

use iron::prelude::*;
use persistent::Read;
use router::Router;
use mount::Mount;
use staticfile::Static;


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
    let nod_to_question = api::questions::nod::NodHandler::new(db_authority.clone());
    let list_questions = api::questions::list::ListHandler::new(db_authority.clone());
    let register_presenter = api::presenters::register::RegistrationHandler::new(db_authority.clone());
    let login_presenter = api::presenters::login::LoginHandler::new(db_authority.clone());
    let list_presentations = api::presentations::list::ListHandler::new(db_authority.clone());

    let mut router = Router::new();
    router.get("/questions", list_questions, "list_questions");
    router.post("/questions/ask", ask_question, "ask_question");
    router.put("/questions/nod", nod_to_question, "nod_to_question");
    router.post("/presenters/register", register_presenter, "register_presenter");
    router.post("/presenters/login", login_presenter, "login_presenter");
    router.get("/presentations", list_presentations, "list_presentations");

    let mut mount = Mount::new();
    mount.mount("/", Static::new(Path::new("../index.html")));
    mount.mount("/api", router);
    mount.mount("/css/", Static::new(Path::new("../static/css")));
    mount.mount("/js/", Static::new(Path::new("../static/js")));

    let mut chain = Chain::new(mount);
    chain.link_before(Read::<bodyparser::MaxBodyLength>::one(MAX_BODY_LENGTH));

    Iron::new(chain).http("127.0.0.1:9001").unwrap();
}
