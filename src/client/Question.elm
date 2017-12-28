module Question exposing (Question, Msg, update, view)

{-| A model of questions asked during presentations, and functions for views etc.
-}

import Html exposing (..)
import Html.Events exposing (onClick)


{-| A model of a question asked during a presentation.
-}
type alias Question =
    { id : String
    , presentation : String
    , questionText : String
    , nods : Int
    , answered : Bool
    }


{-| Local message type for events that can be emitted by the related view.
-}
type Msg
    = QuestionNoddedTo Question


{-| Apply updates to a message in response to a message.
-}
update : Msg -> Question -> ( Question, Cmd Msg )
update msg question =
    case msg of
        QuestionNoddedTo noddedQuestion ->
            if
                question.id == noddedQuestion.id
                -- TODO
            then
                ( { question | nods = question.nods + 1 }, Cmd.none )
            else
                ( question, Cmd.none )


{-| Render a question as a list item, displaying the number of nods (upvotes) it has.
-}
view : Question -> Html Msg
view question =
    li []
        [ text <| toString question.nods
        , text " | "
        , text question.questionText
        , button [ onClick (QuestionNoddedTo question) ] [ text "Nod" ]
        ]
