module Mode.Audience
    exposing
        ( Model
        , Msg(BubblingError)
        , init
        , update
        , view
        )

{-| Models the page that audience members visit to see and post questions while watching a presentation.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, maybe, string)
import Error exposing (Error)
import Resource exposing (Resource)
import Question exposing (Question)


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


{-| The model representing the state of the page audience members interact with.
-}
type alias Model =
    { presentation : String
    , questions : Resource (List Question) String
    , question : String
    , showQuestionInput : Bool
    }


{-| Messages handled by this module.
-}
type Msg
    = QuestionTextReceived String
    | QuestionAsked
    | QuestionNoddedTo Question
    | ShowQuestionInput Bool
    | FromAPI APIResponse
    | BubblingError Error


type APIResponse
    = APIReceivedQuestions (Result Http.Error Question.ListQuestionsResponse)
    | APIQuestionAsked (Result Http.Error Question.QuestionAskedResponse)
    | APIQuestionUpdated (Result Http.Error Question.QuestionUpdateResponse)


{-| The initial state and first message sent by this module when a presentation ID is entered.
-}
init : String -> ( Model, Cmd Msg )
init presentationID =
    let
        questions =
            [ { id = "first"
              , presentation = ""
              , text = "first question here"
              , nods = 32
              , timeAsked = "pretty recently"
              , answer = Resource.Loading
              }
            , { id = "second"
              , presentation = ""
              , text = "Another question. This one has been answered."
              , nods = 100
              , timeAsked = "an hour ago"
              , answer =
                    Resource.Loaded
                        { id = ""
                        , text = "This is an answer!"
                        , timeWritten = "Just now"
                        }
              }
            ]

        model =
            { presentation = presentationID
            , questions = Resource.Loaded questions
            , question = ""
            , showQuestionInput = False
            }

        command =
            -- presentationID
            --    |> Question.list
            --    |> Http.send (APIReceivedQuestions >> FromAPI)
            Cmd.none
    in
        ( model, command )


{-| Update the state of the audience page.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BubblingError _ ->
            -- We don't handle these; they are meant for Main.
            ( model, Cmd.none )

        QuestionTextReceived text ->
            if String.length text <= constMaxQuestionLength then
                ( { model | question = text }, Cmd.none )
            else
                ( model, Cmd.none )

        QuestionAsked ->
            let
                newModel =
                    { model
                        | question = ""
                        , showQuestionInput = False
                    }

                command =
                    Question.ask model.presentation model.question
                        |> Http.send (APIQuestionAsked >> FromAPI)
            in
                ( newModel, command )

        QuestionNoddedTo question ->
            let
                command =
                    question
                        |> Question.nod
                        |> Http.send (APIQuestionUpdated >> FromAPI)
            in
                ( model, command )

        ShowQuestionInput shouldBeOn ->
            ( { model | showQuestionInput = shouldBeOn }, Cmd.none )

        FromAPI (APIReceivedQuestions result) ->
            updateQuestionsReceived result model

        FromAPI (APIQuestionAsked result) ->
            updateQuestionAsked result model

        FromAPI (APIQuestionUpdated result) ->
            updateQuestionUpdated result model


updateQuestionsReceived : Result Http.Error Question.ListQuestionsResponse -> Model -> ( Model, Cmd Msg )
updateQuestionsReceived result model =
    case result of
        Err _ ->
            ( model, Error.bubble BubblingError "Failed to make request." )

        Ok { error, questions } ->
            case error of
                Just errorMessage ->
                    ( model, Error.bubble BubblingError errorMessage )

                Nothing ->
                    ( { model | questions = Resource.Loaded questions }, Cmd.none )


updateQuestionAsked : Result Http.Error Question.QuestionAskedResponse -> Model -> ( Model, Cmd Msg )
updateQuestionAsked result model =
    case result of
        Err error ->
            ( model, Error.bubble BubblingError "Failed to make request." )

        Ok { error, question } ->
            case ( error, question ) of
                ( Just errorMessage, _ ) ->
                    ( model, Error.bubble BubblingError errorMessage )

                ( Nothing, Just question ) ->
                    ( { model | questions = Resource.map ((::) question) model.questions }, Cmd.none )

                ( Nothing, Nothing ) ->
                    ( model, Error.bubble BubblingError "Got an unexpected response from the API server. " )


updateQuestionUpdated : Result Http.Error Question.QuestionUpdateResponse -> Model -> ( Model, Cmd Msg )
updateQuestionUpdated result model =
    case result of
        Err error ->
            ( model, Error.bubble BubblingError "Failed to make request." )

        Ok { error, question } ->
            case ( error, question ) of
                ( Just errorMessage, _ ) ->
                    ( model, Error.bubble BubblingError errorMessage )

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
                    ( model, Error.bubble BubblingError "Got an unexpected response from the API server. " )


{-| The top-level view function used to present elements that audience members interact with.
-}
view : Model -> Html Msg
view model =
    div []
        [ viewAskQuestion model
        , viewQuestionList model
        , viewAskQuestionButton
        ]


viewAskQuestion : Model -> Html Msg
viewAskQuestion model =
    let
        charactersUsed =
            String.length model.question

        limitPercentUsed =
            charactersUsed
                |> toFloat
                |> (\x -> x / constMaxQuestionLength)
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


viewQuestionList : Model -> Html Msg
viewQuestionList model =
    div [ class "content card" ] <|
        case Resource.map (List.map viewQuestion) model.questions of
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


viewQuestion : Question -> Html Msg
viewQuestion question =
    let
        viewAnswer =
            case question.answer of
                Resource.Loaded answer ->
                    div [ class "answer" ]
                        [ p [ class "answer-date" ] [ text <| "Answered at " ++ answer.timeWritten ]
                        , p [ class "answer-text" ] [ text answer.text ]
                        ]

                _ ->
                    div [ class "answer", style [ ( "display", "none" ) ] ] []
    in
        tr [ class "question-item" ]
            [ td [ class "question-nods" ]
                [ a [ href "#", class "button", onClick (QuestionNoddedTo question) ]
                    [ i [ class "fas fa-heart fa-2x" ] []
                    , div [] [ text <| toString question.nods ]
                    ]
                ]
            , td [ class "question-content" ]
                [ p [ class "question-date" ] [ text <| cleanDate question.timeAsked ]
                , p [ class "question-text" ] [ text <| question.text ]
                , viewAnswer
                ]
            ]


viewAskQuestionButton : Html Msg
viewAskQuestionButton =
    div [ class "action-button", onClick (ShowQuestionInput True) ]
        [ a [ href "#", class "button" ]
            [ text "?"
            ]
        ]


cleanDate : String -> String
cleanDate dateStr =
    let
        nth i ls =
            List.head (List.drop i ls)

        parsed =
            dateStr
                |> String.split "T"
                |> nth 1
                |> Maybe.map (String.split ".")
                |> Maybe.andThen (nth 0)
    in
        case parsed of
            Just time ->
                time

            Nothing ->
                "???"
