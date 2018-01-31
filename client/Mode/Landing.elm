module Mode.Landing
    exposing
        ( Model
        , Msg(JoinAudience, Login, Register, BubblingError)
        , AuthenticationAction(..)
        , init
        , update
        , view
        )

{-| Models the page that users land on when they first visit the application site.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Authentication
import Error exposing (Error)


{-| An authentication-related action selected by the user to perform.
-}
type AuthenticationAction
    = NoneSelected
    | LoginAction
    | RegisterAction


{-| The model representing the state of the landing page.
-}
type alias Model =
    { presentationToJoin : String
    , username : String
    , password : String
    , passwordRepeat : String
    , authMode : AuthenticationAction
    }


{-| Messages handled by this module.
-}
type Msg
    = PresentationIDInput String
    | UsernameInput String
    | PasswordInput String
    | PasswordRepeatInput String
    | AuthActionSelected AuthenticationAction
    | JoinAudience { presentation : String }
    | Login Authentication.LoginCredentials
    | Register Authentication.RegistrationInfo
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
            , authMode = NoneSelected
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

        AuthActionSelected action ->
            ( { model | authMode = action }, Cmd.none )

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
    let
        ( cardBody, actions ) =
            case model.authMode of
                NoneSelected ->
                    ( div [] []
                    , [ a [ href "#", class "button", onClick (AuthActionSelected LoginAction) ] [ text "Login" ]
                      , a [ href "#", class "button", onClick (AuthActionSelected RegisterAction) ] [ text "Register" ]
                      ]
                    )

                LoginAction ->
                    ( viewLoginForm
                    , [ a
                            [ href "#"
                            , class "button"
                            , onClick <|
                                Login
                                    { username = model.username
                                    , password = model.password
                                    }
                            ]
                            [ text "Login" ]
                      , a [ href "#", class "button", onClick (AuthActionSelected NoneSelected) ] [ text "Back" ]
                      ]
                    )

                RegisterAction ->
                    ( viewRegisterForm
                    , [ a
                            [ href "#"
                            , class "button"
                            , onClick <|
                                Register
                                    { username = model.username
                                    , password = model.password
                                    , passwordRepeat = model.passwordRepeat
                                    }
                            ]
                            [ text "Register" ]
                      , a [ href "#", class "button", onClick (AuthActionSelected NoneSelected) ] [ text "Back" ]
                      ]
                    )

        body =
            List.append
                [ h2 [] [ text "Presenters" ]
                , p [] [ text "Start your own or manage existing presentations." ]
                ]
                [ cardBody ]
    in
        div [ class "content card" ]
            [ div [ class "card-main" ] body
            , div [ class "hrule" ] []
            , div [ class "card-actions" ] actions
            ]


viewLoginForm : Html Msg
viewLoginForm =
    div []
        [ div []
            [ label [ for "username" ] [ text "Username" ]
            , input [ type_ "text", name "username", onInput UsernameInput ] []
            ]
        , div []
            [ label [ for "password" ] [ text "Password" ]
            , input [ type_ "password", name "password", onInput PasswordInput ] []
            ]
        ]


viewRegisterForm : Html Msg
viewRegisterForm =
    div []
        [ div []
            [ label [ for "username" ] [ text "Username" ]
            , input [ type_ "text", name "username", onInput UsernameInput ] []
            ]
        , div []
            [ label [ for "password" ] [ text "Password" ]
            , input [ type_ "password", name "password", onInput PasswordInput ] []
            ]
        , div []
            [ label [ for "passwordRepeat" ] [ text "Repeat password" ]
            , input [ type_ "password", name "passwordRepeat", onInput PasswordRepeatInput ] []
            ]
        ]
