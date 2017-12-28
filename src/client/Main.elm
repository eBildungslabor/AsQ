module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Http
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
    | GotQuestionsFromAPI (Result Http.Error Question.GetQuestionsResponse)
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
        model =
            { mode = LandingPage
            , presentation = ""
            , questions = []
            , question = ""
            }
    in
        ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SwitchMode QuestionList ->
            ( { model | mode = QuestionList }
            , Http.send GotQuestionsFromAPI <| Question.presentationQuestions model.presentation
            )

        SwitchMode viewMode ->
            ( { model | mode = viewMode }, Cmd.none )

        PresentationIDReceived presID ->
            ( { model | presentation = presID }, Cmd.none )

        PresentationIDSubmitted ->
            ( { model | mode = QuestionList }
            , Http.send GotQuestionsFromAPI <| Question.presentationQuestions model.presentation
            )

        GotQuestionsFromAPI result ->
            updateQuestionsReceived result model

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


updateQuestionsReceived : Result Http.Error Question.GetQuestionsResponse -> Model -> ( Model, Cmd Msg )
updateQuestionsReceived result model =
    case result of
        Err error ->
            let
                _ =
                    Debug.log "ERROR " error
            in
                -- TODO - Error handle
                ( model, Cmd.none )

        Ok { error, questions } ->
            case error of
                Just errorMessage ->
                    let
                        _ =
                            Debug.log "API ERROR " errorMessage
                    in
                        ( model, Cmd.none )

                Nothing ->
                    ( { model | questions = questions }, Cmd.none )


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
            |> List.sortBy .nods
            |> List.reverse
            |> List.map Question.view
            |> List.map (Html.map QuestionAction)
        )


viewAskQuestion : Html Msg
viewAskQuestion =
    div []
        [ textarea
            [ placeholder "Ask your question here"
            , onInput QuestionTextReceived
            ]
            []
        , button [ onClick QuestionAsked ] [ text "Ask" ]
        ]
