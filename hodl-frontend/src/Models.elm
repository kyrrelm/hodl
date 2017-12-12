module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { portfolio : WebData Portfolio
    , coins : WebData (List Coin)
    , currency : WebData Currency
    , route : Route
    , searchCoins : String
    }


initialModel : Route -> Model
initialModel route =
    { portfolio = RemoteData.Loading
    , coins = RemoteData.Loading
    , currency = RemoteData.Loading
    , route = route
    , searchCoins = ""
    }


type alias Coin =
    { symbol : String
    , name : String
    }


type alias Currency =
    { symbol : String
    , btc : String
    , eth : String
    , usd : String
    , eur : String
    }


type alias Portfolio =
    { usdBalance : String
    , eurBalance : String
    , currencies : List CurrencyBalance
    }


type alias CurrencyBalance =
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
    | AddCurrencyRoute
    | NotFoundRoute
