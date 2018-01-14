pub mod error;
pub mod question;

pub use self::error::ModelError;
pub use self::question::Question;


/// Implemented by types that can be saved to and loaded from some persistent medium.
pub trait Resource<AllQuery, FindQuery> {
    type Model;

    /// Store a value in the persistence medium.
    fn save(&self, &mut Self::Model) -> Result<(), ModelError>;

    /// Retrieve a value from the persistence medium.
    fn load(&self, FindQuery) -> Result<Self::Model, ModelError>;

    /// Retrieve all of the instances of a model from a persistence layer satisfying some criteria.
    fn all(&self, AllQuery) -> Result<Vec<Self::Model>, ModelError>;

    /// Update an instance of a model in the persitence layer.
    fn update(&self, &mut Self::Model) -> Result<(), ModelError>;
}
