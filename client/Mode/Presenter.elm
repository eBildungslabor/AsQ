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
    | BubblingError Error


{-| The initial state and first message sent by this module when a presenter logs in.
-}
init : SessionToken -> ( Model, Cmd Msg )
init token =
    let
        model =
            { sessionToken = token
            , presentations = Resource.NotFetched
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
    div [] []


viewPresentationList : Model -> Html Msg
viewPresentationList model =
    div [] []
