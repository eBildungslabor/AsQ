module Presentation
    exposing
        ( Presentation
        )

{-| A model of presentations and functions for managing them.
-}

import Error exposing (Error)
import Question exposing (Question)
import Resource exposing (Resource)


{-| A model of a single presentation.
-}
type alias Presentation =
    { id : String
    , title : String
    , description : String
    , questions : Resource (List Question) Error
    }
