module Mode.Landing
    exposing
        ( Model
        , Msg(JoinAudience, Login, Register, BubblingError)
        , init
        , update
        , view
        )

{-| Models the page that users land on when they first visit the application site.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Error exposing (Error)


{-| The model representing the state of the landing page.
-}
type alias Model =
    { presentationToJoin : String
    , username : String
    , password : String
    , passwordRepeat : String
    }


{-| Messages handled by this module.
-}
type Msg
    = PresentationIDInput String
    | UsernameInput String
    | PasswordInput String
    | PasswordRepeatInput String
    | JoinAudience
        { presentation : String
        }
    | Login
        { username : String
        , password : String
        }
    | Register
        { username : String
        , password : String
        , passwordRepeat : String
        }
    | BubblingError Error


{-| An initial state to start this mode up with.
-}
init : ( Model, Cmd Msg )
init =
    let
        model =
            { presentationToJoin = ""
            , username = ""
            , password = ""
            , passwordRepeat = ""
            }
    in
        ( model, Cmd.none )


{-| Update the state of the landing page in response to some message.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PresentationIDInput id ->
            ( { model | presentationToJoin = id }, Cmd.none )

        UsernameInput name ->
            ( { model | username = name }, Cmd.none )

        PasswordInput pwd ->
            ( { model | password = pwd }, Cmd.none )

        PasswordRepeatInput pwdRepeat ->
            ( { model | passwordRepeat = pwdRepeat }, Cmd.none )

        _ ->
            -- We don't respond to the JoinAudience, Login, Register, or BubblingError messages here.
            -- They are handled by Main.
            ( model, Cmd.none )


{-| Generate a view of the landing page.
-}
view : Model -> Html Msg
view model =
    div []
        [ viewJoinAudience model
        , viewPresenterAuth model
        ]


viewJoinAudience : Model -> Html Msg
viewJoinAudience model =
    div [ class "content card" ]
        [ div [ class "card-main" ]
            [ h2 [] [ text "Join an audience" ]
            , p [] [ text "Enter the ID code for the presentation you're watching." ]
            , input
                [ type_ "text"
                , onInput PresentationIDInput
                ]
                []
            ]
        , div [ class "hrule" ] []
        , div [ class "card-actions" ]
            [ a
                [ href "#"
                , class "button"
                , onClick (JoinAudience { presentation = model.presentationToJoin })
                ]
                [ text "Join" ]
            ]
        ]


viewPresenterAuth : Model -> Html Msg
viewPresenterAuth model =
    div [ class "content card" ]
        [ div [ class "card-main" ]
            [ h2 [] [ text "Presenters" ]
            , p [] [ text "Start your own or manage existing presentations." ]
            ]
        ]
