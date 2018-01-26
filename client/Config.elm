module Config exposing (..)

{-| Configuration module containing static values that may be modified between runs.
-}


{-| The address of the REST API server.
-}
apiServerAddress : String
apiServerAddress =
    "127.0.0.1:9001"
