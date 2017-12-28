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
    | PresentationIDReceived String
    | PresentationIDSubmitted
    | GotQuestions (List Question)
    | QuestionTextReceived String
    | QuestionAsked
    | QuestionAction Question.Msg


type ViewMode
    = LandingPage
    | QuestionList
    | AskQuestion


type alias Model =
    { mode : ViewMode
    , presentation : String
    , questions : List Question
    , question : String
    }


init : ( Model, Cmd Msg )
init =
    let
        initQuestions =
            [ { id = "abc123", presentation = "abc", questionText = "Hello world", nods = 32, answered = False }
            , { id = "dHss31", presentation = "def", questionText = "Are monads burritos?", nods = 100, answered = False }
            , { id = "42Vdf4", presentation = "012", questionText = "Do unicorns exist?", nods = 1, answered = False }
            , { id = "9fAb40", presentation = "345", questionText = "What does the scouter say about his power level?", nods = 9001, answered = False }
            ]

        model =
            { mode = LandingPage
            , presentation = ""
            , questions = initQuestions
            , question = ""
            }
    in
        ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SwitchMode viewMode ->
            ( { model | mode = viewMode }, Cmd.none )

        PresentationIDReceived presID ->
            ( { model | presentation = presID }, Cmd.none )

        PresentationIDSubmitted ->
            -- TODO
            ( { model | mode = QuestionList }, Cmd.none )

        GotQuestions questions ->
            ( { model | questions = questions }, Cmd.none )

        QuestionTextReceived questionText ->
            ( { model | question = questionText }, Cmd.none )

        QuestionAsked ->
            -- TODO
            ( model, Cmd.none )

        QuestionAction questionMsg ->
            let
                updateQuestion =
                    Question.update questionMsg

                ( questions, commands ) =
                    model.questions
                        |> List.map updateQuestion
                        |> List.unzip

                topLevelCommands =
                    List.map (Cmd.map QuestionAction) commands
            in
                ( { model | questions = questions }, Cmd.batch topLevelCommands )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    let
        content =
            case model.mode of
                LandingPage ->
                    [ viewLanding ]

                QuestionList ->
                    [ viewNav model
                    , viewQuestionList model
                    ]

                AskQuestion ->
                    [ viewNav model
                    , viewAskQuestion
                    ]
    in
        div [] content


viewNav : Model -> Html Msg
viewNav model =
    nav []
        [ ul []
            [ li [] [ a [ onClick (SwitchMode QuestionList), href "#" ] [ text "Questions" ] ]
            , li [] [ a [ onClick (SwitchMode AskQuestion), href "#" ] [ text "Ask" ] ]
            ]
        ]


viewLanding : Html Msg
viewLanding =
    div []
        [ input
            [ type_ "text"
            , placeholder "Presentation ID"
            , onInput PresentationIDReceived
            ]
            []
        , button [ onClick PresentationIDSubmitted ] [ text "Go" ]
        ]


viewQuestionList : Model -> Html Msg
viewQuestionList model =
    ul []
        (model.questions
            |> List.map Question.view
            |> List.map (Html.map QuestionAction)
        )


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
