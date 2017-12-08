module Msgs exposing (..)

import Models exposing (Currency)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnFetchPortfolio (WebData (List Currency))
    | OnLocationChange Location
    | ChangeTest String



--    | ChangeLevel Currency Int
--    | OnPlayerSave (Result Http.Error Currency)
