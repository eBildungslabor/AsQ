module QuestionTest exposing (..)

import Test exposing (Test, describe, test)
import Expect exposing (Expectation)
import Question exposing (Question, Msg(QuestionNoddedTo))


suite : Test
suite =
    describe "The Question module"
        [ describe "The update function"
            [ test "updates the question nodded to on QuestionNoddedTo" nodsUpdateCorrectQuestion
            , test "does not update the given question if it was not nodded to" nodDoesntAffectUnrelatedQuestions
            ]
        ]


nodsUpdateCorrectQuestion : () -> Expectation
nodsUpdateCorrectQuestion _ =
    let
        question =
            { id = "abracadabra"
            , presentation = "alakazam"
            , questionText = "haddock"
            , nods = 183
            , answered = False
            }

        message =
            QuestionNoddedTo question

        ( updatedQuestion, _ ) =
            Question.update message question
    in
        Expect.equal updatedQuestion { question | nods = question.nods + 1 }


nodDoesntAffectUnrelatedQuestions : () -> Expectation
nodDoesntAffectUnrelatedQuestions _ =
    let
        question =
            { id = "abracadabra"
            , presentation = "alakazam"
            , questionText = "haddock"
            , nods = 183
            , answered = False
            }

        otherQuestion =
            { question | id = "unrelated" }

        message =
            QuestionNoddedTo question

        ( updatedQuestion, _ ) =
            Question.update message otherQuestion
    in
        Expect.equal updatedQuestion otherQuestion
