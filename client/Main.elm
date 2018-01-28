module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Http
import Error exposing (Error)
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
    | APIQuestionUpdated (Result Http.Error Question.QuestionUpdateResponse)


type Msg
    = SwitchMode ViewMode
    | PresentationIDReceived String
    | PresentationIDSubmitted
    | QuestionTextReceived String
    | QuestionAsked
    | QuestionAction Question.Msg
    | FromAPI APIResponse
    | HideError


type ViewMode
    = LandingPage
    | QuestionList


type alias Model =
    { error : Maybe Error
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
            let
                newModel =
                    { model | mode = QuestionList, error = Nothing }

                command =
                    model.presentation
                        |> Question.presentationQuestions
                        |> Http.send (APIReceivedQuestions >> FromAPI)
            in
                ( newModel, command )

        SwitchMode viewMode ->
            ( { model | mode = viewMode }, Cmd.none )

        PresentationIDReceived presID ->
            ( { model | presentation = presID }, Cmd.none )

        PresentationIDSubmitted ->
            ( { model | mode = QuestionList }
            , model.presentation
                |> Question.presentationQuestions
                |> Http.send (APIReceivedQuestions >> FromAPI)
            )

        QuestionTextReceived questionText ->
            ( { model | question = questionText }, Cmd.none )

        QuestionAsked ->
            ( { model | mode = QuestionList, question = "" }
            , Question.ask model.presentation model.question
                |> Http.send (APIQuestionAsked >> FromAPI)
            )

        QuestionAction (Question.BubblingError error) ->
            ( { model | error = Just error }, Cmd.none )

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

        HideError ->
            ( { model | error = Nothing }, Cmd.none )

        FromAPI (APIReceivedQuestions result) ->
            updateQuestionsReceived result model

        FromAPI (APIQuestionAsked result) ->
            updateQuestionAsked result model

        FromAPI (APIQuestionUpdated result) ->
            updateQuestionUpdated result model


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


updateQuestionUpdated : Result Http.Error Question.QuestionUpdateResponse -> Model -> ( Model, Cmd Msg )
updateQuestionUpdated result model =
    case result of
        Err error ->
            ( { model | error = Just "Failed to make request." }, Cmd.none )

        Ok { error, question } ->
            case ( error, question ) of
                ( Just errorMessage, _ ) ->
                    ( { model | error = Just errorMessage }, Cmd.none )

                ( Nothing, Just question ) ->
                    let
                        pickUpdated newQuestion =
                            if question.id == newQuestion.id then
                                question
                            else
                                newQuestion

                        foldQuestions nextQuestion ls =
                            (pickUpdated nextQuestion) :: ls

                        updatedQuestions =
                            List.foldl foldQuestions [] model.questions
                    in
                        ( { model | questions = updatedQuestions }, Cmd.none )

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
                    [ viewNav model
                    , viewLanding
                    ]

                QuestionList ->
                    [ viewNav model
                    , viewError model
                    , viewAskQuestion
                    , viewQuestionList model
                    ]
    in
        div [] content


viewNav : Model -> Html Msg
viewNav model =
    nav []
        [ ul []
            [ li [ id "logo" ] [ text "AsQ" ]
            ]
        ]


viewLanding : Html Msg
viewLanding =
    div [ class "content card" ]
        [ div [ class "card-main" ]
            [ h2 [] [ text "Join an audience" ]
            , p [] [ text "Enter the ID code for the presentation you're watching." ]
            , input
                [ type_ "text"
                , onInput PresentationIDReceived
                ]
                []
            ]
        , div [ class "hrule" ] []
        , div [ class "card-actions" ]
            [ a [ href "#", class "button", onClick PresentationIDSubmitted ] [ text "Join" ]
            ]
        ]


viewError : Model -> Html Msg
viewError model =
    let
        content =
            case model.error of
                Just errorMessage ->
                    [ text errorMessage
                    , a [ href "#", onClick HideError ] [ text "hide" ]
                    ]

                Nothing ->
                    []
    in
        div [ class "error" ] content


viewQuestionList : Model -> Html Msg
viewQuestionList model =
    let
        rows =
            model.questions
                |> List.sortBy .nods
                |> List.reverse
                |> List.map Question.view
                |> List.map (Html.map QuestionAction)

        attrs =
            if List.length rows == 0 then
                [ style [ ( "display", "none" ) ] ]
            else
                [ class "content card" ]
    in
      div attrs
          [ table [ class "question-list" ]
              [ thead [] []
              , tbody [] rows
              ]
          ]


viewAskQuestion : Html Msg
viewAskQuestion =
    div [ class "content card" ]
        [ div [ class "card-main" ]
            [ h2 [] [ text "Ask a question" ]
            , textarea
                [ onInput QuestionTextReceived
                ]
                []
            ]
        , div [ class "hrule" ] []
        , div [ class "card-actions" ]
            [ a [ href "#", class "button", onClick QuestionAsked ] [ text "Ask" ]
            ]
        ]
