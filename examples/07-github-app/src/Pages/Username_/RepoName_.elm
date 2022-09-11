module Pages.Username_.RepoName_ exposing (Model, Msg, page)

import Api.Data
import Api.GitHub.Repo exposing (Repo)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import Layout exposing (Layout)
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import Util.String
import View exposing (View)


layout : Layout
layout =
    Layout.Navbar


page : Shared.Model -> Route { username : String, repoName : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init route.params
        , update = update
        , subscriptions = subscriptions
        , view = view route.params
        }



-- INIT


type alias Model =
    { repo : Api.Data.Data Repo
    }


init : Params -> () -> ( Model, Effect Msg )
init params () =
    ( { repo = Api.Data.Loading
      }
    , Effect.fromCmd
        (Api.GitHub.Repo.get
            { username = params.username
            , repoName = params.repoName
            , onResponse = GitHubApiResponsed
            }
        )
    )



-- UPDATE


type Msg
    = GitHubApiResponsed (Result Http.Error Repo)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GitHubApiResponsed result ->
            ( { model | repo = Api.Data.fromResult result }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


type alias Params =
    { username : String
    , repoName : String
    }


view : Params -> Model -> View Msg
view params model =
    { title = toTitle params ++ " • GitHub Explorer"
    , body =
        [ viewHero params
        , viewAboutSection model
        ]
    }


toTitle : Params -> String
toTitle params =
    "@{{username}}/{{repoName}}"
        |> String.replace "{{username}}" params.username
        |> String.replace "{{repoName}}" params.repoName


viewHero : Params -> Html Msg
viewHero params =
    section [ class "hero is-light" ]
        [ div [ class "hero-body container has-text-centered" ]
            [ h1 [ class "title is-3" ] [ text (toTitle params) ]
            ]
        ]


viewAboutSection : Model -> Html Msg
viewAboutSection model =
    section [ class "container p-6" ]
        [ case model.repo of
            Api.Data.Loading ->
                text ""

            Api.Data.Failure _ ->
                p [ class "has-text-danger" ] [ text "Something went wrong..." ]

            Api.Data.Success repo ->
                viewRepoAboutSection repo
        ]


viewRepoAboutSection : Repo -> Html Msg
viewRepoAboutSection repo =
    let
        starCountText : String
        starCountText =
            Util.String.pluralize
                { count = repo.starCount
                , singularUnit = "star"
                , pluralUnit = "stars"
                }
    in
    div []
        [ h3 [ class "title is-4" ] [ text "About" ]
        , case repo.description of
            Just description ->
                p [ class "subtitle is-6" ] [ text description ]

            Nothing ->
                text ""
        , p [ class "is-size-7 is-text-gray" ] [ text starCountText ]
        , div [ class "tags pt-3" ]
            (List.map viewTag repo.topics)
        ]


viewTag : String -> Html Msg
viewTag name =
    span [ class "tag is-rounded" ] [ text name ]
