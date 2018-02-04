use std::sync::{Arc, Mutex};


/// A name to tie to a find-all operation on a particular data type.
use chrono::prelude::*;
use sqlite::Connection;

use capabilities::{Capability, CreateTable, FindAll, Save, Update, Delete, Search};
use models::{Id, Question, Presenter, Session};


/// SQLite implements a number of capabilities enabling CRUD operations on various models.
#[derive(Clone)]
pub struct SQLite {
    database: Arc<Mutex<Connection>>,
}

/// A type used as an input for queries to find all of the presentations that a presenter has created.
pub struct PresentationsForPresenter {
    pub presenter_id: Id,
}

impl SQLite {
    /// Create a new SQLite interface wrapping a database connection.
    pub fn new(db_conn: Arc<Mutex<Connection>>) -> Self {
        SQLite {
            database: db_conn,
        }
    }
}

impl Capability<CreateTable<Question>> for SQLite {
    type Data = ();
    type Error = String;

    fn perform(&self, operation: CreateTable<Question>) -> Result<Self::Data, Self::Error> {
        Ok(())
    }
}

impl Capability<Save<Question>> for SQLite {
    type Data = Question;
    type Error = String;

    fn perform(&self, operation: Save<Question>) -> Result<Self::Data, Self::Error> {
        Ok(operation.0)
    }
}

impl Capability<Search<Question>> for SQLite {
    type Data = Question;
    type Error = String;


    fn perform(&self, operation: Search<Question>) -> Result<Self::Data, Self::Error> {
        Ok(operation.0)
    }
}

impl Capability<Update<Question>> for SQLite {
    type Data = ();
    type Error = String;

    fn perform(&self, operation: Update<Question>) -> Result<Self::Data, Self::Error> {
        Ok(())
    }
}

impl Capability<FindAll<QuestionsForPresentation>> for SQLite {
    type Data = Vec<Question>;
    type Error = String;

    fn perform(&self, operation: FindAll<QuestionsForPresentation>) -> Result<Self::Data, Self::Error> {
        Ok(vec![])
    }
}

impl Capability<Save<Presenter>> for SQLite {
    type Data = Presenter;
    type Error = String;

    fn perform(&self, mut operation: Save<Presenter>) -> Result<Self::Data, Self::Error> {
        let mut presenter = operation.0;
        presenter.email_address = Id("saved".to_string());
        Ok(presenter)
    }
}

impl Capability<Search<Presenter>> for SQLite {
    type Data = Presenter;
    type Error = String;

    fn perform(&self, operation: Search<Presenter>) -> Result<Self::Data, Self::Error> {
        Ok(operation.0)
    }
}

impl Capability<Save<Session>> for SQLite {
    type Data = Session;
    type Error = String;

    fn perform(&self, operation: Save<Session>) -> Result<Self::Data, Self::Error> {
        Ok(operation.0)
    }
}
