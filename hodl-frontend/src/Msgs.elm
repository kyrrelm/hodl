module Msgs exposing (..)

import Models exposing (Portfolio)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnFetchPortfolio (WebData Portfolio)
      --    | OnFetchCurrencies (WebData Portfolio)
    | OnLocationChange Location
    | OnNewCurrencyClick
