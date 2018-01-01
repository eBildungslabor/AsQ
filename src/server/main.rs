#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate chrono;
extern crate rocket;
extern crate rocket_contrib;
extern crate serde;
#[macro_use] extern crate serde_derive;
extern crate serde_json;

pub mod models;
mod api;

use api::questions;


fn main() {
    let routes = routes![
        api::index,
        api::css_file,
        api::js_file,
        questions::list::list,
        questions::ask::ask,
        questions::nod::nod,
    ];
    rocket::ignite().mount("/", routes).launch();
}
