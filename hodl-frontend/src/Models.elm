module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { portfolio : WebData Portfolio
    , coins : WebData (List Coin)
    , currency : WebData Currency
    , currencyToSave : WebData CurrencyBalance
    , route : Route
    , searchCoins : String
    , inputCurrencyAmount : String
    }


initialModel : Route -> Model
initialModel route =
    { portfolio = RemoteData.Loading
    , coins = RemoteData.Loading
    , currency = RemoteData.NotAsked
    , currencyToSave = RemoteData.NotAsked
    , route = route
    , searchCoins = ""
    , inputCurrencyAmount = ""
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
    , currencies : List CurrencyOverview
    }


type alias CurrencyBalance =
    { symbol : String
    , balance : String
    }


type alias CurrencyOverview =
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
