module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Http
import Error exposing (Error)
import Question exposing (Question)
import Ports exposing (scrollTop)
import Resource exposing (Resource)


constMaxQuestionLength =
    500


constGreenText =
    "text-green"


constYellowText =
    "text-yellow"


constOrangeText =
    "text-orange"


constRedText =
    "text-red"


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
    | ShowQuestionInput Bool
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
    , questions : Resource (List Question) String
    , question : String
    , showQuestionInput : Bool
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { error = Nothing
            , mode = LandingPage
            , presentation = ""
            , questions = Resource.NotFetched
            , question = ""
            , showQuestionInput = False
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

        ShowQuestionInput newState ->
            ( { model | showQuestionInput = newState }, scrollTop 0 )

        QuestionTextReceived questionText ->
            if String.length questionText <= constMaxQuestionLength then
                ( { model | question = questionText }, Cmd.none )
            else
                ( model, Cmd.none )

        QuestionAsked ->
            ( { model | mode = QuestionList, question = "", showQuestionInput = False }
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
                        |> Resource.map (List.map updateQuestion)
                        |> Resource.map List.unzip
                        |> Resource.loaded
                        |> Maybe.withDefault ( [], [] )

                topLevelCommands =
                    List.map (Cmd.map QuestionAction) commands
            in
                ( { model | questions = Resource.Loaded questions }, Cmd.batch topLevelCommands )

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
                    ( { model | questions = Resource.Loaded questions }, Cmd.none )


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
                    ( { model | questions = Resource.map ((::) question) model.questions }, Cmd.none )

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

                        updateQuestions =
                            List.foldl foldQuestions []
                    in
                        ( { model | questions = Resource.map updateQuestions model.questions }, Cmd.none )

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
                    , viewAskQuestion model
                    , viewQuestionList model
                    , viewAskQuestionButton
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
    case model.error of
        Just errorMessage ->
            div [ class "content card error" ]
                [ div [ class "card-main" ]
                    [ h2 [] [ text "An error has occurred" ]
                    , p [] [ text errorMessage ]
                    ]
                , div [ class "hrule" ] []
                , div [ class "card-actions" ]
                    [ a [ href "#", class "button", onClick HideError ] [ text "Dismiss" ]
                    ]
                ]

        Nothing ->
            div [ style [ ( "display", "none" ) ] ] []


viewQuestionList : Model -> Html Msg
viewQuestionList model =
    let
        questionTransform =
            List.map (Question.view >> Html.map QuestionAction)

        children =
            case Resource.map questionTransform model.questions of
                Resource.Loaded [] ->
                    [ div [ class "card-main" ]
                        [ h2 [] [ text "No questions yet" ]
                        , p [] [ text "Be the first to ask a question!" ]
                        ]
                    , div [ class "hrule" ] []
                    , div [ class "card-actions" ]
                        [ a [ href "#", class "button", onClick (ShowQuestionInput True) ] [ text "Ask" ]
                        ]
                    ]

                Resource.Loaded questions ->
                    [ table [ class "question-list" ]
                        [ thead [] []
                        , tbody [] questions
                        ]
                    ]

                _ ->
                    [ div [ class "card-main" ]
                        [ h2 [] [ text "Loading..." ]
                        , p [] [ text "Plase wait while we fetch the questions for this presentation." ]
                        ]
                    ]
    in
        div [ class "content card" ] children


viewAskQuestion : Model -> Html Msg
viewAskQuestion model =
    let
        charactersUsed =
            String.length model.question

        limitPercentUsed =
            charactersUsed
                |> toFloat
                |> \x ->
                    x
                        / constMaxQuestionLength
                        |> (*) 100.0
                        |> ceiling

        lowRange =
            List.range 1 24

        lowMedRange =
            List.range 25 49

        medHighRange =
            List.range 50 74

        highRange =
            List.range 74 101

        countColor =
            case List.map (List.member limitPercentUsed) [ lowRange, lowMedRange, medHighRange, highRange ] of
                [ True, _, _, _ ] ->
                    constGreenText

                [ _, True, _, _ ] ->
                    constYellowText

                [ _, _, True, _ ] ->
                    constOrangeText

                [ _, _, _, True ] ->
                    constRedText

                _ ->
                    ""

        _ =
            Debug.log "Characters: " ( charactersUsed, limitPercentUsed, countColor )
    in
        if model.showQuestionInput then
            div [ class "content card" ]
                [ div [ class "card-main" ]
                    [ h2 [] [ text "Ask a question" ]
                    , textarea
                        [ onInput QuestionTextReceived
                        , value model.question
                        ]
                        []
                    , div []
                        [ span [ class countColor ]
                            [ text <| (toString charactersUsed) ++ " / " ++ (toString constMaxQuestionLength)
                            ]
                        ]
                    ]
                , div [ class "hrule" ] []
                , div [ class "card-actions" ]
                    [ a [ href "#", class "button", onClick QuestionAsked ] [ text "Ask" ]
                    ]
                ]
        else
            div [ style [ ( "display", "none" ) ] ] []


viewAskQuestionButton : Html Msg
viewAskQuestionButton =
    div [ class "action-button", onClick (ShowQuestionInput True) ]
        [ a [ href "#", class "button" ]
            [ text "?"
            ]
        ]
