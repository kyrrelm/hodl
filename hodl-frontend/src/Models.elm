module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { portfolio : WebData (List Currency)
    , route : Route
    , test : String
    }


initialModel : Route -> Model
initialModel route =
    { portfolio = RemoteData.Loading
    , route = route
    , test = ""
    }


type alias Symbol =
    String


type alias Currency =
    { symbol : Symbol
    , balance : String
    , usdBalance : String
    , eurBalance : String
    , btc : String
    , eth : String
    , usd : String
    , eur : String
    }


type Route
    = PortfolioRoute
    | CurrencyRoute Symbol
    | NotFoundRoute
