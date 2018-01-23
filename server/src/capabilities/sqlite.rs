use std::sync::{Arc, Mutex};

use chrono::prelude::*;
use sqlite::Connection;

use capabilities::{Capability, Save, Update, Delete, Search};
use models::{Id, Presenter};


/// SQLite implements a number of capabilities enabling CRUD operations on various models.
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

impl Capability<Save<Presenter>> for SQLite {
    type Data = Presenter;
    type Error = String; // TODO - Create a real error type.

    fn perform(&self, operation: Save<Presenter>) -> Result<Self::Data, Self::Error> {
        Ok(operation.0)
    }
}

impl Capability<Search<Presenter>> for SQLite {
    type Data = Vec<Presenter>;
    type Error = String;

    fn perform(&self, operation: Search<Presenter>) -> Result<Self::Data, Self::Error> {
        Ok(vec![Presenter {
            email_address: Id("test@site.com".to_string()),
            password_hash: String::new(),
            join_date: Utc::now(),
        }])
    }
}
