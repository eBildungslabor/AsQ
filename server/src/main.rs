extern crate iron;
#[macro_use] extern crate serde_derive;
extern crate serde;
extern crate serde_json;
extern crate router;

mod api;

use iron::prelude::*;
use router::Router;


fn main() {
    let mut router = Router::new();

    router.get("/api/questions", api::questions::list, "list_questions");

    Iron::new(router).http("127.0.0.1:9001").unwrap();
}
