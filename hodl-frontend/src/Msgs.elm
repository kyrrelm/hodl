module Msgs exposing (..)

import Http
import Models exposing (Coin, CurrencyBalance, CurrencyToSave, Jwt, Portfolio, Transaction)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnFetchPortfolio (WebData Portfolio)
    | OnFetchTransactions (WebData (List Transaction))
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
    | OnInputPasswordRepeat String
    | OnClickLogin
    | OnClickLogout
    | OnClickRegister
    | OnClickToRegisterPage
    | OnClickCancelRegister
    | OnToggleSetBalance
    | OnLogin (Result Http.Error Jwt)
    | ReceiveJwtToken (Maybe Jwt)
