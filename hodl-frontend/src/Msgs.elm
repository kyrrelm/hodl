module Msgs exposing (..)

import Models exposing (Portfolio)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnFetchPortfolio (WebData Portfolio)
    | OnLocationChange Location
    | OnNewCurrencyClick
    | ChangeTest String



--    | ChangeLevel Currency Int
--    | OnPlayerSave (Result Http.Error Currency)
