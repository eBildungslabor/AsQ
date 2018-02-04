module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Http
import Mode.Audience
import Mode.Landing
import Mode.Presenter
import Error exposing (Error)
import Question exposing (Question)
import Ports exposing (scrollTop)
import Resource exposing (Resource)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Msg
    = AudienceModeMsg Mode.Audience.Msg
    | LandingModeMsg Mode.Landing.Msg
    | PresenterModeMsg Mode.Presenter.Msg
    | HideError


type ViewMode
    = Landing Mode.Landing.Model
    | Audience Mode.Audience.Model
    | Presenter Mode.Presenter.Model


type alias Model =
    { error : Maybe Error
    , mode : ViewMode
    }


init : ( Model, Cmd Msg )
init =
    let
        ( landingModel, command ) =
            Mode.Landing.init

        model =
            { error = Nothing
            , mode = Landing landingModel
            }
    in
        ( model, Cmd.map LandingModeMsg command )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.mode ) of
        ( AudienceModeMsg (Mode.Audience.BubblingError error), _ ) ->
            ( { model | error = Just error }, Cmd.none )

        ( AudienceModeMsg audMsg, Audience audModel ) ->
            let
                ( newAudModel, command ) =
                    Mode.Audience.update audMsg audModel
            in
                ( { model | mode = Audience newAudModel }, Cmd.map AudienceModeMsg command )

        ( LandingModeMsg (Mode.Landing.BubblingError error), _ ) ->
            ( { model | error = Just error }, Cmd.none )

        ( LandingModeMsg (Mode.Landing.JoinAudience { presentation }), _ ) ->
            let
                ( audModel, audCmd ) =
                    Mode.Audience.init presentation
            in
                ( { model | mode = Audience audModel }, Cmd.map AudienceModeMsg audCmd )

        ( LandingModeMsg (Mode.Landing.Login credentials), _ ) ->
            -- TODO - Login to the server
            let
                ( presModel, presCmd ) =
                    Mode.Presenter.init "sessionToken" "email@address.com"
            in
                ( { model | mode = Presenter presModel }, Cmd.map PresenterModeMsg presCmd )

        ( LandingModeMsg (Mode.Landing.Register info), _ ) ->
            -- TODO - Register new presenter
            let
                ( presModel, presCmd ) =
                    Mode.Presenter.init "sessionToken" "email@address.com"
            in
                ( { model | mode = Presenter presModel }, Cmd.map PresenterModeMsg presCmd )

        ( LandingModeMsg landMsg, Landing landModel ) ->
            let
                ( newLandModel, landCmd ) =
                    Mode.Landing.update landMsg landModel
            in
                ( { model | mode = Landing newLandModel }, Cmd.map LandingModeMsg landCmd )

        ( PresenterModeMsg presMsg, Presenter presModel ) ->
            let
                ( newPresModel, presCmd ) =
                    Mode.Presenter.update presMsg presModel
            in
                ( { model | mode = Presenter newPresModel }, Cmd.map PresenterModeMsg presCmd )

        ( HideError, _ ) ->
            ( { model | error = Nothing }, Cmd.none )

        ( _, _ ) ->
            -- TODO : Find a better way to handle the case where we get an unexpected message
            --        in a mode we can't handle it in.
            let
                _ =
                    Debug.log "Got message " msg

                _ =
                    Debug.log "Model is " model
            in
                ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    div [] <|
        case model.mode of
            Landing landingModel ->
                [ viewNav model
                , Html.map LandingModeMsg <| Mode.Landing.view landingModel
                ]

            Audience audienceModel ->
                [ viewNav model
                , viewError model
                , Html.map AudienceModeMsg <| Mode.Audience.view audienceModel
                ]

            Presenter presenterModel ->
                [ viewNav model
                , viewError model
                , Html.map PresenterModeMsg <| Mode.Presenter.view presenterModel
                ]


viewNav : Model -> Html Msg
viewNav model =
    nav []
        [ ul []
            [ li [ id "logo" ] [ text "AsQ" ]
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
