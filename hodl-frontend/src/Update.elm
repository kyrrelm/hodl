module Update exposing (..)

import Commands exposing (fetchCurrency, fetchSymbols)
import Models exposing (CurrencyBalance, Model)
import Msgs exposing (Msg)
import Navigation exposing (..)
import Routing exposing (addCurrencyPath, newCurrencyPath, parseLocation)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnFetchPortfolio response ->
            ( { model | portfolio = response }, Cmd.none )

        Msgs.OnFetchSymbols response ->
            ( { model | coins = response }, Cmd.none )

        Msgs.OnFetchCurrency response ->
            ( { model | currency = response }, Cmd.none )

        Msgs.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
            ( { model | route = newRoute }, Cmd.none )

        Msgs.OnNewCurrencyClick ->
            ( model, Cmd.batch [ newUrl newCurrencyPath, fetchSymbols ] )

        Msgs.OnAddCurrencyClick symbol ->
            ( model, Cmd.batch [ newUrl addCurrencyPath, fetchCurrency symbol ] )

        Msgs.OnSearchCoins input ->
            ( { model | searchCoins = input }, Cmd.none )
