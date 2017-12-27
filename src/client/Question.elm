module Question exposing (Question, view)

{-| A model of questions asked during presentations, and functions for views etc.
-}

import Html exposing (..)


{-| A model of a question asked during a presentation.
-}
type alias Question =
    { presentation : String
    , questionText : String
    , nods : Int
    , answered : Bool
    }


{-| Render a question as a list item, displaying the number of nods (upvotes) it has.
-}
view : Question -> Html msg
view question =
    li []
        [ text <| toString question.nods
        , text " | "
        , text question.questionText
        ]
