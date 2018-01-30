module Resource exposing (Resource(..), map, loaded)

{-| Resource type that contains data fetched from some external source.
-}


{-| Contains data fetched from an external source.
-}
type Resource a e
    = NotFetched
    | Loading
    | Loaded a
    | Error e


{-| Apply a transformation over data loaded from an external source.
-}
map : (a -> b) -> Resource a e -> Resource b e
map fn resource =
    case resource of
        Loaded data ->
            Loaded <| fn data

        NotFetched ->
            NotFetched

        Loading ->
            Loading

        Error e ->
            Error e


{-| Obtain the loaded data contained in the Resource if any is present.
-}
loaded : Resource a e -> Maybe a
loaded resource =
    case resource of
        Loaded data ->
            Just data

        _ ->
            Nothing
