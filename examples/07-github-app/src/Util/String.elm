module Util.String exposing (pluralize)


pluralize :
    { count : Int
    , singularUnit : String
    , pluralUnit : String
    }
    -> String
pluralize options =
    if options.count == 1 then
        String.fromInt options.count ++ " " ++ options.singularUnit

    else
        String.fromInt options.count ++ " " ++ options.pluralUnit
