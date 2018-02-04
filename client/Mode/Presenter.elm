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
    , emailAddress : String
    , currentPassword : String
    , newPassword : String
    , newPasswordRepeat : String
    , presentations : Resource (List Presentation) Error
    , answeringQuestion : Maybe Question
    , answer : String
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
    | AnswerQuestion Question
    | AnswerInput String
    | SubmitAnswer Question
    | RemoveQuestion Question
    | EmailInput String
    | CurrentPasswordInput String
    | NewPasswordInput String
    | NewPasswordRepeatInput String
    | ChangeEmail
    | ChangePassword
    | DeleteAccount
    | BubblingError Error


{-| The initial state and first message sent by this module when a presenter logs in.
-}
init : SessionToken -> String -> ( Model, Cmd Msg )
init token emailAddress =
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
                          , timeAsked = "some time ago"
                          , answer = Resource.NotFetched
                          }
                        , { id = "secondq"
                          , presentation = "first"
                          , text = "Where do capabilities come from?"
                          , nods = 50
                          , timeAsked = "two minutes ago"
                          , answer = Resource.NotFetched
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
            , emailAddress = emailAddress
            , currentPassword = ""
            , newPassword = ""
            , newPasswordRepeat = ""
            , presentations = Resource.Loaded presentations
            , answeringQuestion = Nothing
            , answer = ""
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

        EmailInput newEmail ->
            ( { model | emailAddress = newEmail }, Cmd.none )

        CurrentPasswordInput currentPassword ->
            ( { model | currentPassword = currentPassword }, Cmd.none )

        NewPasswordInput newPassword ->
            ( { model | newPassword = newPassword }, Cmd.none )

        NewPasswordRepeatInput newPasswordRepeat ->
            ( { model | newPasswordRepeat = newPasswordRepeat }, Cmd.none )

        AnswerQuestion question ->
            ( { model | answeringQuestion = Just question }, Cmd.none )

        AnswerInput answer ->
            ( { model | answer = answer }, Cmd.none )

        SubmitAnswer question ->
            -- TODO : Implement and call API endpoint for answering questions.
            ( { model | answeringQuestion = Nothing, answer = "" }, Cmd.none )

        RemoveQuestion question ->
            -- TODO : Implement and call API endpoint for deleting questions.
            ( model, Cmd.none )

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
        , viewAnswerQuestion model
        , viewQuestions model
        , viewPresentationList model
        , viewAccountSettings model
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
                , a [ href "#", class "button", onClick (ShowNewPresentationForm False) ] [ text "Hide" ]
                ]
            ]
    else
        div [ style [ ( "display", "none" ) ] ] []


viewAnswerQuestion : Model -> Html Msg
viewAnswerQuestion model =
    case model.answeringQuestion of
        Just question ->
            div [ class "content card" ]
                [ div [ class "card-main" ]
                    [ h2 [] [ text "Answer a question" ]
                    , p [] [ text question.text ]
                    , textarea [ onInput AnswerInput ] []
                    ]
                , div [ class "hrule" ] []
                , div [ class "card-actions" ]
                    [ a [ href "#", class "button", onClick (SubmitAnswer question) ] [ text "Answer" ]
                    ]
                ]

        Nothing ->
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
                , div []
                    [ a
                        [ href "#"
                        , class "button"
                        , onClick (AnswerQuestion question)
                        ]
                        [ text "Answer" ]
                    , a
                        [ href "#"
                        , class "dangerous button"
                        , onClick (RemoveQuestion question)
                        ]
                        [ text "Remove" ]
                    ]
                ]
            ]


viewAccountSettings : Model -> Html Msg
viewAccountSettings model =
    div [ class "content card" ]
        [ div [ class "card-main" ]
            [ h2 [] [ text "Account settings" ]
            , h3 [ class "text-regular" ] [ text "Email address" ]
            , input [ type_ "text", onInput EmailInput, value model.emailAddress ] []
            , div []
                [ a [ href "#", class "button", onClick ChangeEmail ] [ text "Change" ]
                ]
            , h3 [ class "text-regular" ] [ text "Password" ]
            , div []
                [ label [ for "currentPassword" ] [ text "Current password" ]
                , input [ type_ "password", name "currentPassword", onInput CurrentPasswordInput ] []
                ]
            , div []
                [ label [ for "password" ] [ text "New password" ]
                , input [ type_ "password", name "password", onInput NewPasswordInput ] []
                ]
            , div []
                [ label [ for "passwordRepeat" ] [ text "Repeat password" ]
                , input [ type_ "password", name "passwordRepeat", onInput NewPasswordRepeatInput ] []
                ]
            , div []
                [ a [ href "#", class "button", onClick ChangePassword ] [ text "Change" ]
                ]
            ]
        , div [ class "hrule" ] []
        , div [ class "card-actions" ]
            [ a [ href "#", class "dangerous button", onClick DeleteAccount ] [ text "Delete account" ]
            ]
        ]


viewCreatePresentationButton : Html Msg
viewCreatePresentationButton =
    div [ class "action-button", onClick (ShowNewPresentationForm True) ]
        [ a [ href "#", class "button" ] [ i [ class "fas fa-plus" ] [] ]
        ]
