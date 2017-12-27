module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Question exposing (Question)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Msg
    = SwitchMode ViewMode
    | GotQuestions (List Question)
    | QuestionTextReceived String
    | QuestionAsked


type ViewMode
    = QuestionList
    | AskQuestion


type alias Model =
    { mode : ViewMode
    , questions : List Question
    , question : String
    }


init : ( Model, Cmd Msg )
init =
    let
        initQuestions =
            [ { presentation = "abc", questionText = "Hello world", nods = 32, answered = False }
            , { presentation = "def", questionText = "Are monads burritos?", nods = 100, answered = False }
            , { presentation = "012", questionText = "Do unicorns exist?", nods = 1, answered = False }
            , { presentation = "345", questionText = "What does the scouter say about his power level?", nods = 9001, answered = False }
            ]
    in
        ( Model QuestionList initQuestions "", Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SwitchMode viewMode ->
            ( { model | mode = viewMode }, Cmd.none )

        GotQuestions questions ->
            ( { model | questions = questions }, Cmd.none )

        QuestionTextReceived questionText ->
            ( { model | question = questionText }, Cmd.none )

        QuestionAsked ->
            -- TODO
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    let
        content =
            case model.mode of
                QuestionList ->
                    viewQuestionList model

                AskQuestion ->
                    viewAskQuestion
    in
        div []
            [ viewNav model
            , content
            ]


viewNav : Model -> Html Msg
viewNav model =
    nav []
        [ ul []
            [ li [] [ a [ onClick (SwitchMode QuestionList), href "#" ] [ text "Questions" ] ]
            , li [] [ a [ onClick (SwitchMode AskQuestion), href "#" ] [ text "Ask" ] ]
            ]
        ]


viewQuestionList : Model -> Html Msg
viewQuestionList model =
    ul [] <|
        List.map Question.view model.questions


viewAskQuestion : Html Msg
viewAskQuestion =
    div []
        [ input
            [ type_ "textarea"
            , placeholder "Ask your question here"
            , onInput QuestionTextReceived
            ]
            []
        , button [ onClick QuestionAsked ] [ text "Ask" ]
        ]
