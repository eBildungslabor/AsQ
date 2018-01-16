use std::sync::{Arc, Mutex};

use sqlite::Connection;

use entities::{QueryEngine, Resource};
use models::{Id, Presenter};

// TODO - Proper error types

/// An `Entity`` that handles Presenters 
pub struct PresenterSQLite {
}

pub struct FindPresenterByEmailSQLite {
    pub email_address: Id,
}

impl PresenterSQLite {
    pub fn new(db: Arc<Mutex<Connection>>) -> Self {
        PresenterSQLite {
        }
    }
}

impl Resource for PresenterSQLite {
    type Model = Presenter;
    type Error = String;

    fn save(&self, presenter: Presenter) -> Result<Presenter, Self::Error> {
        Ok(presenter)
    }

    fn update(&self, presenter: &Presenter) -> Result<(), Self::Error> {
        Ok(())
    }

    fn delete(&self, presenter: Presenter) -> Result<(), Self::Error> {
        Ok(())
    }
}

impl QueryEngine<FindPresenterByEmailSQLite> for PresenterSQLite {
    type Model = Presenter;
    type Error = String;

    fn search(&self, query: FindPresenterByEmailSQLite) -> Result<Vec<Presenter>, Self::Error> {
        Ok(vec![])
    }
}
