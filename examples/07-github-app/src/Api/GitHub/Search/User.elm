module Api.GitHub.Search.User exposing (User, search)

import Http
import Json.Decode
import Url


type alias User =
    { id : Int
    , login : String
    , avatarUrl : String
    }


search :
    { query : String
    , onResponse : Result Http.Error (List User) -> msg
    }
    -> Cmd msg
search options =
    Http.get
        { url = "https://api.github.com/search/users?q=" ++ Url.percentEncode options.query
        , expect = Http.expectJson options.onResponse decoder
        }



-- JSON


decoder : Json.Decode.Decoder (List User)
decoder =
    Json.Decode.field "items" (Json.Decode.list userDecoder)


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map3 User
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "login" Json.Decode.string)
        (Json.Decode.field "avatar_url" Json.Decode.string)
