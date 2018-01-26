use std::sync::{Arc, Mutex};

use chrono::prelude::*;
use sqlite::Connection;

use capabilities::{Capability, CreateTable, Save, Update, Delete, Search};
use models::{Id, Question};


/// SQLite implements a number of capabilities enabling CRUD operations on various models.
#[derive(Clone)]
pub struct SQLite {
    database: Arc<Mutex<Connection>>,
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
