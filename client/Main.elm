module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Http
import Mode.Audience
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
    | PresentationIDReceived String
    | PresentationIDSubmitted
    | HideError


type ViewMode
    = Landing
    | Audience Mode.Audience.Model


type alias Model =
    { error : Maybe Error
    , mode : ViewMode
    , presentation : String
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { error = Nothing
            , mode = Landing
            , presentation = ""
            }
    in
        ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.mode ) of
        ( AudienceModeMsg (Mode.Audience.BubblingError error), _ ) ->
            ( { model | error = Just error }, Cmd.none )

        ( AudienceModeMsg audMsg, Audience audModel ) ->
            let
                ( newAudModel, command ) =
                    Mode.Audience.update audMsg audModel

                newModel =
                    { model | mode = Audience newAudModel }
            in
                ( newModel, Cmd.map AudienceModeMsg command )

        ( PresentationIDReceived presID, _ ) ->
            ( { model | presentation = presID }, Cmd.none )

        ( PresentationIDSubmitted, _ ) ->
            let
                ( state, command ) =
                    Mode.Audience.init model.presentation
            in
                ( { model | mode = Audience state }, Cmd.map AudienceModeMsg command )

        ( HideError, _ ) ->
            ( { model | error = Nothing }, Cmd.none )

        ( _, _ ) ->
            -- TODO : Find a better way to handle the case where we get an unexpected message
            --        in a mode we can't handle it in.
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    div []
        (case model.mode of
            Landing ->
                [ viewNav model
                , viewLanding
                ]

            Audience audienceModel ->
                [ viewNav model
                , viewError model
                , Html.map AudienceModeMsg <| Mode.Audience.view audienceModel
                ]
        )


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
