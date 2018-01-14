module Error exposing (Error, bubble)

{-| Errors dealt with by the application, as well as functions to help produce and manage them.
-}

import Task


{-| Representation of errors.
-}
type alias Error =
    String


{-| Produce a Cmd containing a message with an error.
-}
bubble : (Error -> msg) -> Error -> Cmd msg
bubble toMsg err =
    Task.perform toMsg (Task.succeed err)
