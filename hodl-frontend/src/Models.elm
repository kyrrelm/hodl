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
    , balance : Float
    , btc : Float
    , eth : Float
    , usd : Float
    , eur : Float
    }


type Route
    = PlayersRoute
    | PlayerRoute Symbol
    | NotFoundRoute
