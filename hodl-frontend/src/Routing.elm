module Routing exposing (..)

import Models exposing (Route(..))
import Navigation exposing (Location)
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map PortfolioRoute top
        , map PortfolioRoute (s "portfolio")
        , map CurrencyRoute (s "newCurrency")
        , map AddCurrencyRoute (s "addCurrency" </> string)
        ]


parseLocation : Location -> Route
parseLocation location =
    case parseHash matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


portfolioPath : String
portfolioPath =
    "#portfolio"


newCurrencyPath : String
newCurrencyPath =
    "#newCurrency"


addCurrencyPath : String -> String
addCurrencyPath symbol =
    "#addCurrency/" ++ symbol
