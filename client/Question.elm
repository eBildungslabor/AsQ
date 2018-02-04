module Question
    exposing
        ( Question
        , ListQuestionsResponse
        , QuestionAskedResponse
        , QuestionUpdateResponse
        , list
        , ask
        , nod
        )

{-| A model of questions asked during presentations, and functions for views etc.
-}

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, href)
import Http exposing (Request)
import Json.Decode exposing (Decoder, field, string, int, bool, maybe, succeed)
import Json.Encode as Encode
import Answer exposing (Answer)
import Config
import Error exposing (Error)
import Resource exposing (Resource)


{-| A model of a question asked during a presentation.
-}
type alias Question =
    { id : String
    , presentation : String
    , text : String
    , nods : Int
    , timeAsked : String
    , answer : Resource Answer Error
    }


{-| Response type produced by a request to get a list of questions asked during a presentation.
-}
type alias ListQuestionsResponse =
    { error : Maybe String
    , questions : List Question
    }


{-| Request type produced by a request to ask a question.
-}
type alias AskQuestionRequest =
    { presentation : String
    , question : String
    }


type alias NodToQuestionRequest =
    { question : String
    }


{-| Response type produced by a request to ask a question.
-}
type alias QuestionAskedResponse =
    { error : Maybe String
    , question : Maybe Question
    }


{-| Response type produced by a request to nod to a question.
-}
type alias QuestionUpdateResponse =
    { error : Maybe String
    , question : Maybe Question
    }


{-| Produce an HTTP request that will attempt to decode a list of questions for a presentation.
-}
list : String -> Request ListQuestionsResponse
list presentationID =
    let
        url =
            "http://" ++ Config.apiServerAddress ++ "/api/questions?presentation=" ++ presentationID
    in
        Http.get url listQuestionsResponse


{-| Produces an HTTP request that will POST a new question for a presentation.
-}
ask : String -> String -> Request QuestionAskedResponse
ask presentationID questionText =
    let
        url =
            "http://" ++ Config.apiServerAddress ++ "/api/questions/ask"

        body =
            { presentation = presentationID, question = questionText }
                |> askQuestionRequest
                |> Http.jsonBody
    in
        Http.post url body questionAskedResponse


{-| Produces a PUT request to have a question be "nodded at".
-}
nod : Question -> Request QuestionUpdateResponse
nod question =
    let
        _ =
            Debug.log "Nodding to" question

        url =
            "http://" ++ Config.apiServerAddress ++ "/api/questions/nod"

        body =
            { question = question.id }
                |> nodToQuestionRequest
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , url = url
            , headers = []
            , body = body
            , expect = Http.expectJson questionUpdateResponse
            , timeout = Nothing
            , withCredentials = False
            }


question : Decoder Question
question =
    Json.Decode.map6 Question
        (field "id" string)
        (field "presentation" string)
        (field "text" string)
        (field "nods" int)
        (field "timeAsked" string)
        (succeed Resource.NotFetched)


listQuestionsResponse : Decoder ListQuestionsResponse
listQuestionsResponse =
    Json.Decode.map2 ListQuestionsResponse
        (field "error" (maybe string))
        (field "questions" (Json.Decode.list question))


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


nodToQuestionRequest : NodToQuestionRequest -> Encode.Value
nodToQuestionRequest { question } =
    Encode.object
        [ ( "question", Encode.string question ) ]


questionUpdateResponse : Decoder QuestionUpdateResponse
questionUpdateResponse =
    Json.Decode.map2 QuestionAskedResponse
        (field "error" (maybe string))
        (field "question" (maybe question))
