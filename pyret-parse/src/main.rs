#![feature(proc_macro_hygiene, decl_macro)]
#![feature(str_strip)]

#[macro_use]
extern crate rocket;

use rocket_contrib::json::Json;
use rocket_cors::{Cors, CorsOptions};
use serde::Deserialize;
use std::{
    collections::HashSet,
    io::{Cursor, Write},
};

fn main() {
    rocket::ignite()
        .mount("/", routes![parse])
        .attach(Cors::from_options(&CorsOptions::default()).unwrap())
        .launch();
}
