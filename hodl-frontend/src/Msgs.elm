module Msgs exposing (..)

import Http
import Models exposing (Coin, Currency, Portfolio, PortfolioEntry)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnFetchPortfolio (WebData Portfolio)
    | OnFetchSymbols (WebData (List Coin))
    | OnFetchCurrency (WebData Currency)
    | OnLocationChange Location
    | OnNewCurrencyClick
    | OnSearchCoins String
    | OnAddCurrencyClick String
    | OnCurrencyAmountInput String
    | OnClickCurrencySave
    | OnCurrencySave (Result Http.Error PortfolioEntry)
