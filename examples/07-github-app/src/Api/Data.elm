module Api.Data exposing (Data(..), fromResult)

import Http


type Data value
    = Loading
    | Success value
    | Failure Http.Error


fromResult : Result Http.Error value -> Data value
fromResult result =
    case result of
        Ok value ->
            Success value

        Err httpError ->
            Failure httpError
