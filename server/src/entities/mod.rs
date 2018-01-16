mod presenter;
mod initializers;

pub use entities::presenter::{PresenterSQLite, FindPresenterByEmailSQLite};
pub use entities::initializers::{init_sqlite_tables};


/// Resources manage the persistence of models of application data.
pub trait Resource {
    type Model;
    type Error;

    /// Store an instance of a model in the persistence medium.
    fn save(&self, Self::Model) -> Result<Self::Model, Self::Error>;

    /// Update an instance of the model in place within the persistence medium.
    fn update(&self, &Self::Model) -> Result<(), Self::Error>;

    /// Remove an instance of the model from the persistence medium.
    fn delete(&self, Self::Model) -> Result<(), Self::Error>;
}

/// Queries abstract search operations, enabling a variety of interfaces for looking up model instances.
pub trait QueryEngine<Query> {
    type Model;
    type Error;

    /// Perform a search query, potentially returning an instance of the model that the query is defined on.
    fn search(&self, Query) -> Result<Vec<Self::Model>, Self::Error>;
}

macro_rules! mock_resource {
    ($name:ident, M = $m:ty, E = $e:ty, save = $s:expr, update = $u:expr, delete = $d:expr) => {
        struct $name;

        impl Resource for $name {
            type Model = $m;
            type Error = $e;

            fn save(&self, model: $m) -> Result<$m, $e> {
                $s(model)
            }

            fn update(&self, model: &$m) -> Result<(), $e> {
                $u(model)
            }

            fn delete(&self, model: $m) -> Result<(), $e> {
                $d(model)
            }
        }
    }
}

macro_rules! mock_query_engine {
    ($name:ident, Q = $q:ty, M = $m:ty, E = $e:ty, search = $s:expr) => {
        struct $name;

        impl QueryEngine<$q> for $name {
            type Model = $m;
            type Error = $e;

            fn search(&self, query: $q) -> Result<Vec<$m>, $e> {
                $s(query)
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn can_create_mock_entities() {
        #[derive(Debug, PartialEq, Eq)]
        struct Empty;

        mock_resource!(
            ArbitraryResource, M = Empty, E = Empty,
            save = |model| Ok(model),
            update = |_| Ok(()),
            delete = |_| Ok(())
        );

        assert_eq!(Empty, ArbitraryResource.save(Empty).unwrap());
        assert_eq!((), ArbitraryResource.update(&Empty).unwrap());
        assert_eq!((), ArbitraryResource.delete(Empty).unwrap());
    }

    #[test]
    fn can_create_mock_queries() {
        #[derive(Debug, PartialEq, Eq)]
        struct Empty;

        mock_query_engine!(
            ArbitraryQuery, Q = Empty, M = Empty, E = Empty,
            search = |_| Ok(vec![Empty])
        );

        assert_eq!(Empty, ArbitraryQuery.search(Empty).unwrap()[0]);
    }
}
