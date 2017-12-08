module Routing exposing (..)

import Models exposing (Route(..), Symbol)
import Navigation exposing (Location)
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map PortfolioRoute top
        , map CurrencyRoute (s "players" </> string)
        , map PortfolioRoute (s "players")
        ]


parseLocation : Location -> Route
parseLocation location =
    case parseHash matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


playersPath : String
playersPath =
    "#players"


playerPath : Symbol -> String
playerPath id =
    "#players/" ++ id
