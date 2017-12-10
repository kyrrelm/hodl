module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { portfolio : WebData Portfolio
    , symbols : WebData (List Symbol)
    , route : Route
    }


initialModel : Route -> Model
initialModel route =
    { portfolio = RemoteData.Loading
    , symbols = RemoteData.Loading
    , route = route
    }


type alias Symbol =
    { symbol : String
    , name : String
    }


type alias Portfolio =
    { usdBalance : String
    , eurBalance : String
    , currencies : List Currency
    }


type alias Currency =
    { symbol : String
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
    | CurrencyRoute
    | NotFoundRoute
