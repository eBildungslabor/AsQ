module Presentation
    exposing
        ( Presentation
        )

{-| A model of presentations and functions for managing them.
-}


{-| A model of a single presentation.
-}
type alias Presentation =
    { id : String
    , title : String
    , description : String
    }
