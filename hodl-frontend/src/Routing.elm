module Routing exposing (..)

import Models exposing (Route(..))
import Navigation exposing (Location)
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map PortfolioRoute top
        , map PortfolioRoute (s "portfolio")
        , map NewCurrencyRoute (s "newCurrency")
        , map AddCurrencyRoute (s "addCurrency" </> string)
        , map CurrencyRoute (s "currency" </> string)
        , map LoginRoute (s "login")
        , map RegisterRoute (s "register")
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


loginPath : String
loginPath =
    "#login"


registerPath : String
registerPath =
    "#register"


addCurrencyPath : String -> String
addCurrencyPath symbol =
    "#addCurrency/" ++ symbol


currencyPath : String -> String
currencyPath symbol =
    "#currency/" ++ symbol
