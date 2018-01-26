use iron::prelude::*;
use iron::{Headers, status};
use iron_test::{request, response};
use serde_json as json;
use sqlite::Connection;

use server::api;


#[test]
fn cannot_ask_questions_for_presentations_that_dont_exist() {
    /*
    let db_name = "cannot_ask_questions_for_presentations_that_dont_exist.db";
    let db = setup_db(db_name);

    let handler = api::questions::AskHandler::new(db);
    let response = request::post(
        "http://127.0.0.1:9001",
        Headers::new(),
        "{\"presentation\": \"notavalidpresentationid\", \"question\": \"just testing\"}",
        &handler
    ).unwrap();

    let body: json::Value = json::from_reader(response.body.unwrap()).unwrap();
    assert_eq!(response.status.unwrap(), status::BadRequest);

    teardown_db(db_name, db);
    */
}
