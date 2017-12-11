module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { portfolio : WebData Portfolio
    , coins : WebData (List Coin)
    , route : Route
    , searchCoins : String
    }


initialModel : Route -> Model
initialModel route =
    { portfolio = RemoteData.Loading
    , coins = RemoteData.Loading
    , route = route
    , searchCoins = ""
    }


type alias Coin =
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
