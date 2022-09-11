module Api.GitHub.User.Repo exposing (Repo, latest)

import Http
import Json.Decode
import Url exposing (Protocol(..))


type alias Repo =
    { id : Int
    , name : String
    , url : String
    , description : Maybe String
    , starCount : Int
    , topics : List String
    }


latest :
    { username : String
    , onResponse : Result Http.Error (List Repo) -> msg
    }
    -> Cmd msg
latest options =
    Http.get
        { url =
            "http://localhost:5000/users/{{username}}/repos?sort=created&per_page=15"
                |> String.replace "{{username}}" options.username
        , expect = Http.expectJson options.onResponse decoder
        }


decoder : Json.Decode.Decoder (List Repo)
decoder =
    Json.Decode.list repoDecoder


repoDecoder : Json.Decode.Decoder Repo
repoDecoder =
    Json.Decode.map6 Repo
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "url" Json.Decode.string)
        (Json.Decode.field "description" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "stargazers_count" Json.Decode.int)
        (Json.Decode.field "topics" (Json.Decode.list Json.Decode.string))
