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
            [ { id = "first", title = "Using Capabilities to design APIs", description = "", questions = Resource.NotFetched }
            , { id = "second", title = "A critical evaluation of Golang", description = "", questions = Resource.NotFetched }
            , { id = "third", title = "This is my third presentation ever!", description = "", questions = Resource.NotFetched }
            ]

        model =
            { sessionToken = token
            , presentations = Resource.Loaded presentations
            , expanded = Nothing
            , newPresentationTitle = ""
            , newPresentationDescription = ""
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
    ( model, Cmd.none )


{-| The top-level view function used to present elements that presenters interact with.
-}
view : Model -> Html Msg
view model =
    div []
        [ viewCreatePresentation
        , viewPresentationList model
        ]


viewCreatePresentation : Html Msg
viewCreatePresentation =
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
    li [ class "card-item" ]
        [ a [ href "#", class "button", onClick (Expanded presentation) ] [ text presentation.title ]
        ]
