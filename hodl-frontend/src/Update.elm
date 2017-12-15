module Update exposing (..)

import Commands exposing (fetchCurrency, fetchPortfolio, fetchSymbols, saveCurrencyCmd)
import Models exposing (CurrencyOverview, Model)
import Msgs exposing (Msg)
import Navigation exposing (..)
import RemoteData exposing (WebData)
import Routing exposing (addCurrencyPath, newCurrencyPath, parseLocation, portfolioPath)


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

        Msgs.OnCurrencyAmountInput input ->
            ( { model | inputCurrencyAmount = input }, Cmd.none )

        Msgs.OnClickCurrencySave ->
            case model.currency of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Success currency ->
                    ( { model | currencyToSave = RemoteData.Loading }, saveCurrencyCmd ( currency, model.inputCurrencyAmount ) )

                RemoteData.Failure error ->
                    ( model, Cmd.none )

        Msgs.OnCurrencySave (Ok portfolioEntry) ->
            ( { model | currencyToSave = RemoteData.Success portfolioEntry }, Cmd.batch [ newUrl portfolioPath, fetchPortfolio ] )

        Msgs.OnCurrencySave (Err error) ->
            ( { model | currencyToSave = RemoteData.Failure error }, Cmd.none )
