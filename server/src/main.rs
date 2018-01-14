extern crate bodyparser;
extern crate iron;
extern crate persistent;
#[macro_use] extern crate serde_derive;
extern crate serde;
extern crate serde_json;
extern crate router;

mod api;

use iron::prelude::*;
use persistent::Read;
use router::Router;


const MAX_BODY_LENGTH: usize = 10 * 1024 * 1024;


fn main() {
    let mut router = Router::new();
    router.get("/api/questions", api::questions::list, "list_questions");
    router.post("/api/questions", api::questions::ask, "ask_question");
    router.put("/api/questions/:id/nod", api::questions::nod, "nod_to_question");

    let mut chain = Chain::new(router);
    chain.link_before(Read::<bodyparser::MaxBodyLength>::one(MAX_BODY_LENGTH));

    Iron::new(chain).http("127.0.0.1:9001").unwrap();
}
