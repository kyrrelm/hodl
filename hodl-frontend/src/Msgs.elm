module Msgs exposing (..)

import Models exposing (Coin, Portfolio)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnFetchPortfolio (WebData Portfolio)
    | OnFetchSymbols (WebData (List Coin))
    | OnLocationChange Location
    | OnNewCurrencyClick
    | OnSearchCoins String
