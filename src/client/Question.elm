module Question
    exposing
        ( Question
        , Msg(QuestionNoddedTo)
        , GetQuestionsResponse
        , QuestionAskedResponse
        , QuestionUpdateResponse
        , update
        , view
        , presentationQuestions
        , ask
        , nod
        )

{-| A model of questions asked during presentations, and functions for views etc.
-}

import Html exposing (..)
import Html.Events exposing (onClick)
import Http exposing (Request)
import Json.Decode exposing (Decoder, field, string, int, bool, list, maybe)
import Json.Encode as Encode
import Config


{-| A model of a question asked during a presentation.
-}
type alias Question =
    { id : String
    , presentation : String
    , questionText : String
    , nods : Int
    , answered : Bool
    }


{-| Local message type for events that can be emitted by the related view.
-}
type Msg
    = QuestionNoddedTo Question
    | GotNodResponse (Result Http.Error QuestionUpdateResponse)


{-| Response type produced by a request to get a list of questions asked during a presentation.
-}
type alias GetQuestionsResponse =
    { error : Maybe String
    , questions : List Question
    }


{-| Request type produced by a request to ask a question.
-}
type alias AskQuestionRequest =
    { presentation : String
    , question : String
    }


{-| Response type produced by a request to ask a question.
-}
type alias QuestionAskedResponse =
    { error : Maybe String
    , question : Maybe Question
    }


{-| Response type produced by a request to update a question.
-}
type alias QuestionUpdateResponse =
    { error : Maybe String
    , question : Maybe Question
    }


{-| Apply updates to a message in response to a message.
-}
update : Msg -> Question -> ( Question, Cmd Msg )
update msg question =
    case msg of
        QuestionNoddedTo noddedQuestion ->
            ( question
            , Http.send GotNodResponse <| nod noddedQuestion
            )

        GotNodResponse result ->
            case result of
                Err error ->
                    -- TODO How can I avoid swallowing this error?
                    ( question, Cmd.none )

                Ok response ->
                    case ( response.error, response.question ) of
                        ( _, Just updatedQuestion ) ->
                            if updatedQuestion.id == question.id then
                                ( updatedQuestion, Cmd.none )
                            else
                                ( question, Cmd.none )

                        ( _, _ ) ->
                            -- TODO How can I avoid swallowing this error?
                            ( question, Cmd.none )


{-| Render a question as a list item, displaying the number of nods (upvotes) it has.
-}
view : Question -> Html Msg
view question =
    li []
        [ text <| toString question.nods
        , text " | "
        , text question.questionText
        , button [ onClick (QuestionNoddedTo question) ] [ text "Nod" ]
        ]


{-| Produce an HTTP request that will attempt to decode a list of questions for a presentation.
-}
presentationQuestions : String -> Request GetQuestionsResponse
presentationQuestions presentationID =
    let
        url =
            "http://" ++ Config.apiServerAddress ++ "/api/questions?presentation=" ++ presentationID
    in
        Http.get url getQuestionResponse


{-| Produces an HTTP request that will POST a new question for a presentation.
-}
ask : String -> String -> Request QuestionAskedResponse
ask presentationID questionText =
    let
        url =
            "http://" ++ Config.apiServerAddress ++ "/api/questions"

        body =
            Http.jsonBody <| askQuestionRequest { presentation = presentationID, question = questionText }
    in
        Http.post url body questionAskedResponse


{-| Produces a PUT request to have a question be "nodded at".
-}
nod : Question -> Request QuestionUpdateResponse
nod question =
    let
        url =
            "http://" ++ Config.apiServerAddress ++ "/api/questions/" ++ question.id ++ "/nod"
    in
        Http.request
            { method = "PUT"
            , url = url
            , headers = []
            , body = Http.emptyBody
            , expect = Http.expectJson questionUpdateResponse
            , timeout = Nothing
            , withCredentials = False
            }


question : Decoder Question
question =
    Json.Decode.map5 Question
        (field "id" string)
        (field "presentation" string)
        (field "questionText" string)
        (field "nods" int)
        (field "answered" bool)


getQuestionResponse : Decoder GetQuestionsResponse
getQuestionResponse =
    Json.Decode.map2 GetQuestionsResponse
        (field "error" (maybe string))
        (field "questions" (list question))


askQuestionRequest : AskQuestionRequest -> Encode.Value
askQuestionRequest { presentation, question } =
    Encode.object
        [ ( "presentation", Encode.string presentation )
        , ( "question", Encode.string question )
        ]


questionAskedResponse : Decoder QuestionAskedResponse
questionAskedResponse =
    Json.Decode.map2 QuestionAskedResponse
        (field "error" (maybe string))
        (field "question" (maybe question))


questionUpdateResponse : Decoder QuestionUpdateResponse
questionUpdateResponse =
    Json.Decode.map2 QuestionAskedResponse
        (field "error" (maybe string))
        (field "question" (maybe question))
