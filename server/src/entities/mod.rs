/// Entities are responsible for managing the persistence of models of application data.
pub trait Entity {
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
pub trait Query {
    type Model;
    type Error;

    /// Perform a search query, potentially returning an instance of the model that the query is defined on.
    fn search(&self) -> Result<Self::Model, Self::Error>;
}

macro_rules! mock_entity {
    ($name:ident, M = $m:ty, E = $e:ty, save = $s:expr, update = $u:expr, delete = $d:expr) => {
        struct $name;

        impl Entity for $name {
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

macro_rules! mock_query {
    ($name:ident, M = $m:ty, E = $e:ty, search = $s:expr) => {
        struct $name;

        impl Query for $name {
            type Model = $m;
            type Error = $e;

            fn search(&self) -> Result<$m, $e> {
                $s()
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

        mock_entity!(
            ArbitraryEntity, M = Empty, E = Empty,
            save = |model| Ok(model),
            update = |_| Ok(()),
            delete = |_| Ok(())
        );

        assert_eq!(Empty, ArbitraryEntity.save(Empty).unwrap());
        assert_eq!((), ArbitraryEntity.update(&Empty).unwrap());
        assert_eq!((), ArbitraryEntity.delete(Empty).unwrap());
    }

    #[test]
    fn can_create_mock_queries() {
        #[derive(Debug, PartialEq, Eq)]
        struct Empty;

        mock_query!(
            ArbitraryQuery, M = Empty, E = Empty,
            search = || Ok(Empty)
        );

        assert_eq!(Empty, ArbitraryQuery.search().unwrap());
    }
}
