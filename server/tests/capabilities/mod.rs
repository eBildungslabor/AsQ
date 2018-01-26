mod sqlite;

use std::fs;
use std::sync::{Arc, Mutex};

use sqlite::Connection;

use server::capabilities::sqlite::SQLite;
use server::capabilities::initializers::init_sqlite_tables;


fn setup_db(db_name: &str) -> SQLite {
    let db = SQLite::new(Arc::new(Mutex::new(Connection::open(db_name).unwrap())));
    init_sqlite_tables(&db).unwrap();
    db
}


fn teardown_db(db_name: &str, _db: SQLite) {
    fs::remove_file(db_name).unwrap()
}
