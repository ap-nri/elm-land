module Pages.Home_ exposing (Model, Msg, page)

import Api.GitHub.Search.User
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (alt, attribute, class, placeholder, src, type_, value)
import Html.Events
import Http
import Layout exposing (Layout)
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


layout : Layout
layout =
    Layout.Navbar


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { searchInput : String
    , users : Result Http.Error (List Api.GitHub.Search.User.User)
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { searchInput = ""
      , users = Ok []
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UserChangedSearchInput String
    | UserSubmittedSearchForm
    | GitHubSearchApiResponded (Result Http.Error (List Api.GitHub.Search.User.User))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserChangedSearchInput newValue ->
            ( { model | searchInput = newValue }
            , Effect.none
            )

        UserSubmittedSearchForm ->
            ( model
            , Effect.fromCmd
                (Api.GitHub.Search.User.search
                    { query = model.searchInput
                    , onResponse = GitHubSearchApiResponded
                    }
                )
            )

        GitHubSearchApiResponded result ->
            ( { model | users = result }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "GitHub Explorer"
    , body =
        [ viewHero
        , main_ [ class "container p-6" ]
            [ viewSearchForm model
            , viewListOfUsers model
            ]
        ]
    }


viewHero : Html msg
viewHero =
    section [ class "hero is-link" ]
        [ div [ class "hero-body container has-text-centered" ]
            [ h1 [ class "title is-1" ] [ text "GitHub Explorer" ]
            , h2 [ class "subtitle is-4" ] [ text "Browse those repos!" ]
            ]
        ]


viewSearchForm : Model -> Html Msg
viewSearchForm model =
    form [ class "is-flex is-justify-content-center", Html.Events.onSubmit UserSubmittedSearchForm ]
        [ div [ class "field has-addons" ]
            [ div [ class "control" ]
                [ input
                    [ class "input"
                    , placeholder "Search by username"
                    , attribute "aria-label" "Search by username"
                    , Html.Events.onInput UserChangedSearchInput
                    , value model.searchInput
                    ]
                    []
                ]
            , div [ class "control" ]
                [ button
                    [ type_ "submit"
                    , class "button is-link"
                    ]
                    [ text "Search" ]
                ]
            ]
        ]


viewListOfUsers : Model -> Html Msg
viewListOfUsers model =
    div [ class "px-6 pt-6" ]
        [ case model.users of
            Err httpError ->
                p [ class "has-text-danger" ] [ text "Something went wrong..." ]

            Ok users ->
                div [] (List.map viewUser users)
        ]


viewUser : Api.GitHub.Search.User.User -> Html Msg
viewUser user =
    a
        [ Route.Path.href (Route.Path.Username_ { username = user.login })
        , class "box"
        ]
        [ div [ class "media" ]
            [ div [ class "media-left" ]
                [ figure [ class "image is-64x64" ]
                    [ img [ src user.avatarUrl, alt user.login ] []
                    ]
                ]
            , div [ class "media-content" ]
                [ div [ class "content" ]
                    [ p [ class "has-text-weight-bold" ] [ text user.login ]
                    ]
                ]
            ]
        ]
