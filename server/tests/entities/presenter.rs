use std::fs;
use std::sync::{Arc, Mutex};

use chrono::prelude::*;
use sqlite::Connection;

use server::entities::*;
use server::models::{Id, Presenter};


#[test]
fn can_find_saved_presenters() {
    let test_db = "can_find_saved_presenters.db";
    let db = Connection::open(test_db).unwrap();

    init_sqlite_tables(&db).unwrap();
    let db = Arc::new(Mutex::new(db));

    let presenter_entity = PresenterSQLite::new(db.clone());
    let presenter = Presenter {
        email_address: Id("test_presenter@site.web".to_string()),
        password_hash: "abcdef0123456789".to_string(),
        join_date: Utc::now(),
    };

    let presenter = presenter_entity.save(presenter).unwrap();
    assert_eq!(presenter.email_address.0, "test_presenter@site.web".to_string());
    assert_eq!(presenter.password_hash, "abcdef0123456789".to_string());

    let query = FindPresenterByEmailSQLite {
        email_address: Id("test_presenter@site.web".to_string()),
    };
    let found = presenter_entity.search(query).unwrap();
    assert_eq!(found[0].email_address.0, presenter.email_address.0);
    assert_eq!(found[0].password_hash, presenter.password_hash);

    fs::remove_file(test_db).unwrap();
}
