module Layouts.Navbar exposing (layout)

import Html exposing (..)
import Html.Attributes exposing (class)
import Route.Path
import View exposing (View)


layout : { page : View msg } -> View msg
layout { page } =
    { title = page.title
    , body =
        [ viewNavbar
        , div [ class "page" ] page.body
        ]
    }


viewNavbar : Html msg
viewNavbar =
    header [ class "container p-4 mb-0" ]
        [ div [ class "level" ]
            [ div [ class "level-left" ]
                [ div [ class "level-item" ]
                    [ a
                        [ Route.Path.href Route.Path.Home_
                        , class "title is-6"
                        ]
                        [ text "🗺 GitHub Explorer" ]
                    ]
                ]
            ]
        ]
