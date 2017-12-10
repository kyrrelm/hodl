module Msgs exposing (..)

import Models exposing (Portfolio, Symbol)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnFetchPortfolio (WebData Portfolio)
    | OnFetchSymbols (WebData (List Symbol))
    | OnLocationChange Location
    | OnNewCurrencyClick
    | OnSearchCoins String
