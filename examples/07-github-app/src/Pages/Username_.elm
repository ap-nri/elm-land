module Pages.Username_ exposing (Model, Msg, page)

import Api.Data
import Api.GitHub.User exposing (User)
import Api.GitHub.User.Repo exposing (Repo)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (alt, class, src)
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


page : Shared.Model -> Route { username : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init route
        , update = update
        , subscriptions = subscriptions
        , view = view route.params.username
        }



-- INIT


type alias Model =
    { user : Api.Data.Data User
    , repos : Api.Data.Data (List Repo)
    }


init : Route { username : String } -> () -> ( Model, Effect Msg )
init route () =
    ( { user = Api.Data.Loading
      , repos = Api.Data.Loading
      }
    , Effect.batch
        [ fetchUserInformation route
        , fetchUsersLatestRepos route
        ]
    )


fetchUserInformation : Route { username : String } -> Effect Msg
fetchUserInformation route =
    Effect.fromCmd
        (Api.GitHub.User.get
            { username = route.params.username
            , onResponse = GitHubUserApiResponded
            }
        )


fetchUsersLatestRepos : Route { username : String } -> Effect Msg
fetchUsersLatestRepos route =
    Effect.fromCmd
        (Api.GitHub.User.Repo.latest
            { username = route.params.username
            , onResponse = GitHubRepoApiResponded
            }
        )



-- UPDATE


type Msg
    = GitHubUserApiResponded (Result Http.Error Api.GitHub.User.User)
    | GitHubRepoApiResponded (Result Http.Error (List Api.GitHub.User.Repo.Repo))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GitHubUserApiResponded result ->
            ( { model | user = Api.Data.fromResult result }
            , Effect.none
            )

        GitHubRepoApiResponded result ->
            ( { model | repos = Api.Data.fromResult result }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : String -> Model -> View Msg
view username model =
    { title = username ++ " • GitHub Explorer"
    , body =
        case model.user of
            Api.Data.Loading ->
                []

            Api.Data.Failure httpError ->
                [ viewHero
                    { title = "Oops!"
                    , subtitle = Just "Something went wrong..."
                    , image = Nothing
                    }
                ]

            Api.Data.Success user ->
                [ viewHero
                    { title = user.name
                    , subtitle = user.bio
                    , image = Just user.avatarUrl
                    }
                , viewUserRepositories user model
                ]
    }


viewHero :
    { title : String
    , subtitle : Maybe String
    , image : Maybe String
    }
    -> Html Msg
viewHero options =
    section [ class "hero is-light" ]
        [ div [ class "hero-body is-flex is-align-items-center is-flex-direction-column has-text-centered" ]
            [ case options.image of
                Just imageUrl ->
                    figure [ class "image is-128x128" ]
                        [ img [ class "is-rounded", src imageUrl, alt options.title ] []
                        ]

                Nothing ->
                    text ""
            , h1 [ class "title is-2" ] [ text options.title ]
            , case options.subtitle of
                Just subtitle ->
                    h2 [ class "subtitle is-5" ] [ text subtitle ]

                Nothing ->
                    text ""
            ]
        ]


viewUserRepositories : User -> Model -> Html Msg
viewUserRepositories user model =
    case model.repos of
        Api.Data.Loading ->
            text ""

        Api.Data.Failure _ ->
            p [ class "has-text-danger" ] [ text "Something went wrong..." ]

        Api.Data.Success repos ->
            section [ class "container p-6" ]
                [ h3 [ class "title is-4" ] [ text "Latest repositories" ]
                , div [] (List.map (viewUserRepo user) repos)
                ]


viewUserRepo : User -> Repo -> Html Msg
viewUserRepo user repo =
    let
        starCountText : String
        starCountText =
            Util.String.pluralize
                { count = repo.starCount
                , singularUnit = "star"
                , pluralUnit = "stars"
                }
    in
    a
        [ Route.Path.href
            (Route.Path.Username___RepoName_
                { username = user.login
                , repoName = repo.name
                }
            )
        , class "box"
        ]
        [ div [ class "media" ]
            [ div [ class "media-content" ]
                [ div [ class "content" ]
                    [ div [ class "has-text-weight-bold  is-size-5" ] [ text repo.name ]
                    , case repo.description of
                        Just description ->
                            div [ class "has-text-grey is-size-7" ] [ text description ]

                        Nothing ->
                            text ""
                    , div [ class "is-flex is-size-7" ]
                        [ text
                            (starCountText
                                :: repo.topics
                                |> String.join " • "
                            )
                        ]
                    ]
                ]
            ]
        ]
