module Api.GitHub.User exposing (User, get)

import Http
import Json.Decode
import Url


type alias User =
    { id : Int
    , login : String
    , avatarUrl : String
    , name : String
    , bio : Maybe String
    }


get :
    { username : String
    , onResponse : Result Http.Error User -> msg
    }
    -> Cmd msg
get options =
    Http.get
        { url = "http://localhost:5000/users/" ++ options.username
        , expect = Http.expectJson options.onResponse decoder
        }



-- JSON


decoder : Json.Decode.Decoder User
decoder =
    Json.Decode.map5 User
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "login" Json.Decode.string)
        (Json.Decode.field "avatar_url" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "bio" (Json.Decode.maybe Json.Decode.string))
