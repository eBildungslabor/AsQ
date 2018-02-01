module Mode.Presenter
    exposing
        ( Model
        , Msg(BubblingError)
        , init
        , update
        , view
        )

{-| Models the page that authenticated presenters interact with to create and manage their presentations.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Authentication exposing (SessionToken)
import Error exposing (Error)
import Presentation exposing (Presentation)
import Resource exposing (Resource)
import Question exposing (Question)


{-| The model representing the state of the presenter page.
-}
type alias Model =
    { sessionToken : SessionToken
    , presentations : Resource (List Presentation) Error
    , expanded : Maybe Presentation
    , newPresentationTitle : String
    , newPresentationDescription : String
    , showPresentationForm : Bool
    }


{-| Messages handled by this module.
-}
type Msg
    = Expanded Presentation
    | TitleInput String
    | DescriptionInput String
    | CreatePresentation
    | ShowNewPresentationForm Bool
    | HideQuestions
    | BubblingError Error


{-| The initial state and first message sent by this module when a presenter logs in.
-}
init : SessionToken -> ( Model, Cmd Msg )
init token =
    let
        presentations =
            [ { id = "first"
              , title = "Using Capabilities to design APIs"
              , description = ""
              , questions =
                    Resource.Loaded
                        [ { id = "firstq"
                          , presentation = "first"
                          , text = "What good are they?"
                          , nods = 32
                          , answered = True
                          , timeAsked = "some time ago"
                          }
                        , { id = "secondq"
                          , presentation = "first"
                          , text = "Where do capabilities come from?"
                          , nods = 50
                          , answered = False
                          , timeAsked = "two minutes ago"
                          }
                        ]
              }
            , { id = "second"
              , title = "A critical evaluation of Golang"
              , description = ""
              , questions = Resource.NotFetched
              }
            , { id = "third"
              , title = "This is my third presentation ever!"
              , description = ""
              , questions = Resource.NotFetched
              }
            ]

        model =
            { sessionToken = token
            , presentations = Resource.Loaded presentations
            , expanded = Nothing
            , newPresentationTitle = ""
            , newPresentationDescription = ""
            , showPresentationForm = False
            }

        command =
            -- sessionToken
            --     |> Presentation.list
            --     |> Http.send (APIReceivedPresentations >> FromAPI)
            Cmd.none
    in
        ( model, command )


{-| The top-level update function used to update the page's state in response to a message.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowNewPresentationForm on ->
            ( { model | showPresentationForm = on }, Cmd.none )

        HideQuestions ->
            ( { model | expanded = Nothing }, Cmd.none )

        Expanded presentation ->
            let
                newExpanded =
                    -- This code will handle toggling the question list if the user clicks the same
                    -- presentation multiple times.
                    case model.expanded of
                        Just expanded ->
                            if expanded.id == presentation.id then
                                Nothing
                            else
                                Just presentation

                        Nothing ->
                            Just presentation
            in
                ( { model | expanded = newExpanded }, Cmd.none )

        _ ->
            ( model, Cmd.none )


{-| The top-level view function used to present elements that presenters interact with.
-}
view : Model -> Html Msg
view model =
    div []
        [ viewCreatePresentation model
        , viewQuestions model
        , viewPresentationList model
        , viewCreatePresentationButton
        ]


viewCreatePresentation : Model -> Html Msg
viewCreatePresentation model =
    if model.showPresentationForm then
        div [ class "content card" ]
            [ div [ class "card-main" ]
                [ h2 [] [ text "Create a new presentation" ]
                , div []
                    [ label [ for "title" ] [ text "Title" ]
                    , input [ type_ "text", name "title", onInput TitleInput ] []
                    ]
                , div []
                    [ label [ for "description" ] [ text "Description" ]
                    , textarea [ name "description", onInput DescriptionInput ] []
                    ]
                ]
            , div [ class "hrule" ] []
            , div [ class "card-actions" ]
                [ a [ href "#", class "button", onClick CreatePresentation ] [ text "Create" ]
                ]
            ]
    else
        div [ style [ ( "display", "none" ) ] ] []


viewPresentationList : Model -> Html Msg
viewPresentationList model =
    let
        expandQuestionsIfSelected =
            List.map <| viewPresentation model.expanded

        children =
            case Resource.map expandQuestionsIfSelected model.presentations of
                Resource.Loaded [] ->
                    [ div [ class "card-main" ]
                        [ h2 [] [ text "No presentations yet" ]
                        , p [] [ text "Create your first presentation!" ]
                        ]
                    , div [ class "hrule" ] []
                    , div [ class "card-actions" ]
                        [ a
                            [ href "#"
                            , class "button"
                            , onClick (ShowNewPresentationForm True)
                            ]
                            [ text "Create" ]
                        ]
                    ]

                Resource.Loaded presentations ->
                    [ ul [] presentations
                    ]

                _ ->
                    [ div [ class "card-main" ]
                        [ h2 [] [ text "Loading..." ]
                        , p [] [ text "Please wait while we fetch your presentations." ]
                        ]
                    ]
    in
        div [ class "content card" ] children


viewPresentation : Maybe Presentation -> Presentation -> Html Msg
viewPresentation expanded presentation =
    let
        numQuestionsInfo =
            case presentation.questions of
                Resource.Loaded questions ->
                    questions
                        |> List.length
                        |> toString
                        |> (\s -> s ++ " questions")

                Resource.Loading ->
                    "Loading questions..."

                Resource.NotFetched ->
                    "Loading questions..."

                _ ->
                    "Questions not available"
    in
        li [ class "card-item" ]
            [ a [ href "#", class "text-medium", onClick (Expanded presentation) ] [ text presentation.title ]
            , p [ class "text-small" ] [ text numQuestionsInfo ]
            ]


viewQuestions : Model -> Html Msg
viewQuestions model =
    let
        ( title, styles, content ) =
            case model.expanded of
                Just presentation ->
                    case presentation.questions of
                        Resource.Loaded questions ->
                            ( presentation.title
                            , []
                            , table [ class "question-list" ]
                                [ thead [] []
                                , tbody [] <| List.map viewQuestion questions
                                ]
                            )

                        _ ->
                            ( presentation.title
                            , []
                            , p [] [ text "Loading questions..." ]
                            )

                Nothing ->
                    ( ""
                    , [ ( "display", "none" ) ]
                    , div [] []
                    )
    in
        div [ class "content card", style styles ]
            [ div [ class "card-main" ]
                [ h2 [] [ text title ]
                , content
                ]
            , div [ class "hrule" ] []
            , div [ class "card-actions" ]
                [ a [ href "#", class "button", onClick HideQuestions ] [ text "Close" ]
                ]
            ]


viewQuestion : Question -> Html Msg
viewQuestion question =
    let
        people =
            if question.nods == 0 || question.nods > 1 then
                "people"
            else
                "person"

        nodMsg =
            (toString question.nods) ++ " " ++ people ++ " nodded to this"
    in
        tr [ class "question-item" ]
            [ td [ class "question-text" ]
                [ p [] [ text question.text ]
                , p [ class "text-small" ] [ text nodMsg ]
                ]
            ]


viewCreatePresentationButton : Html Msg
viewCreatePresentationButton =
    div [ class "action-button", onClick (ShowNewPresentationForm True) ]
        [ a [ href "#", class "button" ] [ i [ class "fas fa-plus" ] [] ]
        ]
