/// Compose multiple capabilities to perform different operations.
///
/// # Examples
///
/// ```rust
/// capability!(ReadAndWriteUsers for SQLite,
///             composing { Search<User>, User, DBError },
///                       { Update<User>, (),   DBError });
/// ```
///
/// The above macro invocation will create a new trait called `ReadAndWriteUsers` as well as provide an
/// implementation of it for a `SQLite` type.  This assumes that `SQLite` implements:
///
/// * Capability<Search<User>, Data = User, Error = DBError>, and
/// * Capability<Update<User>, Data = (),   Error = DBError>
macro_rules! capability {
    ($name:ident for $type:ty,
     composing $({$operations:ty, $d:ty, $e:ty}),+) => {
        trait $name: $(Capability<$operations, Data = $d, Error = $e>+)+ {}
        impl $name for $type {}
    };
}


pub mod sqlite;


/// Represents "the ability to perform a particular operation."
pub trait Capability<Operation> {
    type Data;
    type Error;

    fn perform(&self, operation: Operation) -> Result<Self::Data, Self::Error>;
}

/// A name to tie to save operations on particular data types.
pub struct Save<T>(pub T);

/// A name to tie to update operations on particular data types.
pub struct Update<T>(pub T);

/// A name to tie to delete operations on particular data types.
pub struct Delete<T>(pub T);

/// A name to tie to search operations on particular data types.
pub struct Search<T>(pub T);

