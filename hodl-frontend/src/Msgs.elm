module Msgs exposing (..)

import Http
import Models exposing (Coin, Currency, CurrencyBalance, Portfolio)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnFetchPortfolio (WebData Portfolio)
    | OnFetchSymbols (WebData (List Coin))
    | OnFetchCurrency (WebData Currency)
    | OnLocationChange Location
    | OnClickNewCurrency
    | OnInputSearchCoin String
    | OnClickAddCurrency String
    | OnInputCurrencyAmount String
    | OnClickCurrencySave
    | OnCurrencySave (Result Http.Error CurrencyBalance)
    | OnClickNavBarName
