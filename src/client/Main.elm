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


type APIResponse
    = APIReceivedQuestions (Result Http.Error Question.GetQuestionsResponse)
    | APIQuestionAsked (Result Http.Error Question.QuestionAskedResponse)


type Msg
    = SwitchMode ViewMode
    | PresentationIDReceived String
    | PresentationIDSubmitted
    | QuestionTextReceived String
    | QuestionAsked
    | QuestionAction Question.Msg
    | FromAPI APIResponse


type ViewMode
    = LandingPage
    | QuestionList
    | AskQuestion


type alias Model =
    { error : Maybe String
    , mode : ViewMode
    , presentation : String
    , questions : List Question
    , question : String
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { error = Nothing
            , mode = LandingPage
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
            , Http.send (\x -> FromAPI <| APIReceivedQuestions x) <| Question.presentationQuestions model.presentation
            )

        SwitchMode viewMode ->
            ( { model | mode = viewMode }, Cmd.none )

        PresentationIDReceived presID ->
            ( { model | presentation = presID }, Cmd.none )

        PresentationIDSubmitted ->
            ( { model | mode = QuestionList }
            , Http.send (\x -> FromAPI <| APIReceivedQuestions x) <| Question.presentationQuestions model.presentation
            )

        QuestionTextReceived questionText ->
            ( { model | question = questionText }, Cmd.none )

        QuestionAsked ->
            ( { model | mode = QuestionList, question = "" }
            , Http.send (\x -> FromAPI <| APIQuestionAsked x) <| Question.ask model.presentation model.question
            )

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

        FromAPI (APIReceivedQuestions result) ->
            updateQuestionsReceived result model

        FromAPI (APIQuestionAsked result) ->
            updateQuestionAsked result model


{-| Apply an update to the application model when a response to a request to get questions from the API is received.
-}
updateQuestionsReceived : Result Http.Error Question.GetQuestionsResponse -> Model -> ( Model, Cmd Msg )
updateQuestionsReceived result model =
    case result of
        Err error ->
            ( { model | error = Just "Failed to make request." }, Cmd.none )

        Ok { error, questions } ->
            case error of
                Just errorMessage ->
                    ( { model | error = Just errorMessage }, Cmd.none )

                Nothing ->
                    ( { model | questions = questions }, Cmd.none )


{-| Apply an update to the application model when a response to a question being asked is received rom the API.
-}
updateQuestionAsked : Result Http.Error Question.QuestionAskedResponse -> Model -> ( Model, Cmd Msg )
updateQuestionAsked result model =
    case result of
        Err error ->
            ( { model | error = Just "Failed to make request." }, Cmd.none )

        Ok { error, question } ->
            case ( error, question ) of
                ( Just errorMessage, _ ) ->
                    ( { model | error = Just errorMessage }, Cmd.none )

                ( Nothing, Just question ) ->
                    ( { model | questions = question :: model.questions }, Cmd.none )

                ( Nothing, Nothing ) ->
                    ( { model | error = Just "Got an unexpected response from the API server. " }, Cmd.none )


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
                    , viewError model
                    , viewQuestionList model
                    ]

                AskQuestion ->
                    [ viewNav model
                    , viewError model
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


viewError : Model -> Html Msg
viewError model =
    let
        content =
            case model.error of
                Just errorMessage ->
                    [ text errorMessage ]

                Nothing ->
                    []
    in
        div [ class "error" ] content


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
