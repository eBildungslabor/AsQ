use std::sync::{Arc, Mutex};

use sqlite::Connection;

use entities::{QueryEngine, Resource};
use models::{Id, Presenter};

// TODO - Proper error types

/// An `Entity`` that handles Presenters 
pub struct PresenterSQLite {
}

pub struct FindPresenterByEmail {
    pub email_address: Id,
}

pub struct FindAllPresenters;

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

impl QueryEngine<FindPresenterByEmail> for PresenterSQLite {
    type Model = Presenter;
    type Error = String;

    fn search(&self, query: FindPresenterByEmail) -> Result<Vec<Presenter>, Self::Error> {
        Ok(vec![])
    }
}

impl QueryEngine<FindAllPresenters> for PresenterSQLite {
    type Model = Presenter;
    type Error = String;

    fn search(&self, query: FindAllPresenters) -> Result<Vec<Presenter>, Self::Error> {
        Ok(vec![])
    }
}
