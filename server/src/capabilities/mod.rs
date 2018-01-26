use std::marker::PhantomData;


/// Compose multiple capabilities to perform different operations.
#[macro_export]
macro_rules! capability {
    ($name:ident for $type:ty,
     composing $({$operations:ty, $d:ty, $e:ty}),+) => {
        pub trait $name: $(Capability<$operations, Data = $d, Error = $e>+)+ {}
        impl $name for $type {}
    };
}


pub mod sqlite;
pub mod initializers;


/// Represents "the ability to perform a particular operation."
pub trait Capability<Operation> {
    type Data;
    type Error;

    fn perform(&self, operation: Operation) -> Result<Self::Data, Self::Error>;
}

/// An operation to create a table for a particular model.
pub struct CreateTable<T>(PhantomData<T>);

/// A name to tie to save operations on particular data types.
pub struct Save<T>(pub T);

/// A name to tie to update operations on particular data types.
pub struct Update<T>(pub T);

/// A name to tie to delete operations on particular data types.
pub struct Delete<T>(pub T);

/// A name to tie to search operations on particular data types.
pub struct Search<T>(pub T);


impl<T> CreateTable<T> {
    pub fn new() -> Self {
        CreateTable(PhantomData)
    }
}
