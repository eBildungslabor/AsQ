#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate rocket;
extern crate rocket_contrib;
extern crate serde;
#[macro_use] extern crate serde_derive;
extern crate serde_json;

pub mod models;
mod api;

use api::questions;


#[get("/hello")]
fn hello() -> &'static str {
    "Hello, world"
}

fn main() {
    let routes = routes![
        hello,
        api::index,
        api::css_file,
        api::js_file,
        questions::questions_list,
        questions::ask,
    ];
    rocket::ignite().mount("/", routes).launch();
}
