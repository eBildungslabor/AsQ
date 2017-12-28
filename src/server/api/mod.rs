pub mod questions;

use std::path::{Path, PathBuf};
use rocket::response::NamedFile;

#[get("/")]
pub fn index() -> NamedFile {
    NamedFile::open(Path::new("index.html")).unwrap()
}

#[get("/css/<file..>")]
pub fn css_file(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("static/css/").join(file)).ok()
}

#[get("/js/<file..>")]
pub fn js_file(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("static/js/").join(file)).ok()
}