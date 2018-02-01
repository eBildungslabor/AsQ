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

        _ ->
            ( model, Cmd.none )


{-| The top-level view function used to present elements that presenters interact with.
-}
view : Model -> Html Msg
view model =
    div []
        [ viewCreatePresentation model
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
    div [ class "content card" ] <|
        case Resource.map (List.map viewPresentation) model.presentations of
            Resource.Loaded [] ->
                [ div [ class "card-main" ]
                    [ h2 [] [ text "No presentations yet" ]
                    , p [] [ text "Create your first presentation!" ]
                    ]
                , div [ class "hrule" ] []
                , div [ class "card-actions" ]
                    [ a [ href "#", class "button", onClick (ShowNewPresentationForm True) ] [ text "Create" ]
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


viewPresentation : Presentation -> Html Msg
viewPresentation presentation =
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
            [ a [ href "#", class "button", onClick (Expanded presentation) ] [ text presentation.title ]
            , p [ class "text-small" ] [ text numQuestionsInfo ]
            ]


viewCreatePresentationButton : Html Msg
viewCreatePresentationButton =
    div [ class "action-button", onClick (ShowNewPresentationForm True) ]
        [ a [ href "#", class "button" ] [ i [ class "fas fa-plus" ] [] ]
        ]
