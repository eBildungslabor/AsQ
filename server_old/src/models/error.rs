use std::error::Error;


/// Represents the possible errors that may need to be handled when interacting with a persistence medium.
#[derive(Debug)]
pub enum ModelError {
    DatabaseError(Box<Error>),
}
