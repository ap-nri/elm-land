module Api.GitHub.Repo exposing (Repo, get)

import Http
import Json.Decode


type alias Repo =
    { name : String
    , owner : Owner
    , description : Maybe String
    , url : String
    , starCount : Int
    , topics : List String
    , defaultBranch : String
    }


type alias Owner =
    { login : String
    , avatarUrl : String
    }


get :
    { username : String
    , repoName : String
    , onResponse : Result Http.Error Repo -> msg
    }
    -> Cmd msg
get options =
    Http.get
        { url =
            "https://api.github.com/repos/{{username}}/{{repoName}}"
                |> String.replace "{{username}}" options.username
                |> String.replace "{{repoName}}" options.repoName
        , expect = Http.expectJson options.onResponse decoder
        }


decoder : Json.Decode.Decoder Repo
decoder =
    Json.Decode.map7 Repo
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "owner" ownerDecoder)
        (Json.Decode.field "description" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "html_url" Json.Decode.string)
        (Json.Decode.field "stargazers_count" Json.Decode.int)
        (Json.Decode.field "topics" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "default_branch" Json.Decode.string)


ownerDecoder : Json.Decode.Decoder Owner
ownerDecoder =
    Json.Decode.map2 Owner
        (Json.Decode.field "login" Json.Decode.string)
        (Json.Decode.field "avatar_url" Json.Decode.string)
