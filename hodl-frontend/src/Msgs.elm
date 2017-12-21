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
    | OnGoBack Int
    | OnClickNewCurrency
    | OnInputSearchCoin String
    | OnClickAddCurrency String
    | OnInputCurrencyPrice String
    | OnInputCurrencyAmount String
    | OnClickCurrencySave
    | OnCurrencySave (Result Http.Error CurrencyBalance)
    | OnClickNavBarName
