module Answer
    exposing
        ( Answer
        )

{-| A model of answers written in response to questions asked by audience members.
-}


{-| A model of an answer to a question, written by a presenter.
-}
type alias Answer =
    { id : String
    , text : String
    , timeWritten : String
    }
