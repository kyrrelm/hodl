module Msgs exposing (..)

import Http
import Models exposing (Coin, CurrencyBalance, CurrencyToSave, Jwt, Portfolio)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnFetchPortfolio (WebData Portfolio)
    | OnFetchSymbols (WebData (List Coin))
    | OnFetchCurrency (WebData CurrencyToSave)
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
    | OnInputEmail String
    | OnInputPassword String
    | OnClickLogin
    | OnLogin (Result Http.Error Jwt)
