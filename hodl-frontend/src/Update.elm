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

        Msgs.OnClickNewCurrency ->
            ( model, Cmd.batch [ newUrl newCurrencyPath, fetchSymbols ] )

        Msgs.OnClickNavBarName ->
            ( model, Cmd.batch [ newUrl portfolioPath, fetchPortfolio ] )

        Msgs.OnClickAddCurrency symbol ->
            ( model, Cmd.batch [ newUrl addCurrencyPath, fetchCurrency symbol ] )

        Msgs.OnInputSearchCoin input ->
            ( { model | searchCoins = input }, Cmd.none )

        Msgs.OnInputCurrencyAmount input ->
            ( { model | inputCurrencyAmount = input }, Cmd.none )

        Msgs.OnClickCurrencySave ->
            case model.currency of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Success currency ->
                    case validateInputCurrencyAmount model.inputCurrencyAmount of
                        Nothing ->
                            ( { model | currencyToSave = RemoteData.Loading }, saveCurrencyCmd ( currency, model.inputCurrencyAmount ) )

                        Just error ->
                            ( { model | inputCurrencyAmountError = Just error }, Cmd.none )

                RemoteData.Failure error ->
                    ( model, Cmd.none )

        Msgs.OnCurrencySave (Ok portfolioEntry) ->
            ( { model | currencyToSave = RemoteData.Success portfolioEntry }, Cmd.batch [ newUrl portfolioPath, fetchPortfolio ] )

        Msgs.OnCurrencySave (Err error) ->
            ( { model | currencyToSave = RemoteData.Failure error }, Cmd.none )


validateInputCurrencyAmount : String -> Maybe String
validateInputCurrencyAmount currencyAmount =
    case String.toFloat currencyAmount of
        Ok amount ->
            Nothing

        Err e ->
            Just "That is not a number"
