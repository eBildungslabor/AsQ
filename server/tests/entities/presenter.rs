use std::fs;
use std::sync::{Arc, Mutex};

use chrono::prelude::*;
use sqlite::Connection;

use server::entities::*;
use server::models::{Id, Presenter};


macro_rules! query_capability {
    (for => $type:ty, name => $name:ident, query => $($queries:tt),+) => {
        trait $name: $(QueryEngine<$queries, Model = Presenter, Error = String>+)+ {}

        impl $name for $type {}
    };
}

query_capability! {
    for   => PresenterSQLite,
    name  => AllOrOne,
    query => FindAllPresenters, FindPresenterByEmail
}

// fn insecure_reset_passwords<R, E>(resource_manager: &R, query_engine: &E) -> bool
//     where R: Resource<Model = Presenter, Error = String>,
//           E: QueryEngine<FindPresenterByEmail, Model = Presenter, Error = String>
// + QueryEngine<FindAllPresenters, Model = Presenter, Error = String>
fn insecure_reset_passwords<R, T>(resource_manager: &R, query_engine: &T) -> bool
    where R: Resource<Model = Presenter, Error = String>,
          T: AllOrOne
{
    let query = FindPresenterByEmail {
        email_address: Id("test_presenter@site.web".to_string()),
    };
    let query2 = FindAllPresenters;
    let mut found = query_engine.search(query2).unwrap();
    for presenter in found.iter_mut() {
        presenter.password_hash = "Totally insecure now".to_string();
        resource_manager.update(&presenter).unwrap();
    }
    true
}

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

    let query = FindPresenterByEmail {
        email_address: Id("test_presenter@site.web".to_string()),
    };
    let found = presenter_entity.search(query).unwrap();
    assert_eq!(found[0].email_address.0, presenter.email_address.0);
    assert_eq!(found[0].password_hash, presenter.password_hash);

    insecure_reset_passwords(&presenter_entity, &presenter_entity);

    fs::remove_file(test_db).unwrap();
}
