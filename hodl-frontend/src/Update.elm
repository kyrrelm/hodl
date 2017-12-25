module Update exposing (..)

import Commands exposing (fetchCurrency, fetchPortfolio, fetchSymbols, loginCmd, saveCurrencyCmd)
import Models exposing (CurrencyOverview, Jwt, Model, Route)
import Msgs exposing (Msg)
import Navigation exposing (..)
import Ports exposing (..)
import RemoteData exposing (WebData)
import Result exposing (Result)
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

        Msgs.OnGoBack amount ->
            ( model, back amount )

        Msgs.OnClickNewCurrency ->
            ( model, Cmd.batch [ newUrl newCurrencyPath, fetchSymbols ] )

        Msgs.OnClickNavBarName ->
            ( model, Cmd.batch [ newUrl portfolioPath, fetchPortfolio ] )

        Msgs.OnClickAddCurrency symbol ->
            ( { model | inputCurrencyAmountError = Nothing }, Cmd.batch [ newUrl (addCurrencyPath symbol), fetchCurrency symbol ] )

        Msgs.OnInputSearchCoin input ->
            ( { model | searchCoins = input }, Cmd.none )

        Msgs.OnInputCurrencyPrice input ->
            ( { model | inputCurrencyPrice = input, inputCurrencyPriceError = Nothing }, Cmd.none )

        Msgs.OnInputCurrencyAmount input ->
            ( { model | inputCurrencyAmount = input, inputCurrencyAmountError = Nothing }, Cmd.none )

        Msgs.OnClickCurrencySave ->
            case model.currency of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Success currency ->
                    case currencyIsValid model of
                        True ->
                            ( { model | currencyToSave = RemoteData.Loading }, saveCurrencyCmd ( currency, model.inputCurrencyAmount, model.inputCurrencyPrice ) )

                        False ->
                            ( { model
                                | inputCurrencyAmountError =
                                    validatePositiveNumber model.inputCurrencyAmount
                                , inputCurrencyPriceError =
                                    validateEmptyStringOrPositiveNumber model.inputCurrencyPrice
                              }
                            , Cmd.none
                            )

                RemoteData.Failure error ->
                    ( model, Cmd.none )

        Msgs.OnCurrencySave (Ok portfolioEntry) ->
            ( { model | currencyToSave = RemoteData.Success portfolioEntry }, Cmd.batch [ newUrl portfolioPath, fetchPortfolio ] )

        Msgs.OnCurrencySave (Err error) ->
            ( { model | currencyToSave = RemoteData.Failure error }, Cmd.none )

        Msgs.OnInputEmail input ->
            ( { model | inputEmail = input }, Cmd.none )

        Msgs.OnInputPassword input ->
            ( { model | inputPassword = input }, Cmd.none )

        Msgs.OnClickLogin ->
            ( model, loginCmd ( model.inputEmail, model.inputPassword ) )

        Msgs.OnLogin jwtResponse ->
            case jwtResponse of
                Ok jwt ->
                    ( model, storeJwtToken jwt )

                Err error ->
                    ( model, Cmd.none )

        Msgs.ReceiveJwtToken maybeJwt ->
            case maybeJwt of
                Nothing ->
                    ( model, Cmd.none )

                Just jwt ->
                    case model.route of
                        Models.LoginRoute ->
                            ( { model | jwt = Just jwt }, Cmd.batch [ fetchPortfolio, fetchSymbols, newUrl portfolioPath ] )

                        Models.PortfolioRoute ->
                            ( { model | jwt = Just jwt }, Cmd.batch [ fetchPortfolio, fetchSymbols ] )

                        Models.CurrencyRoute ->
                            ( { model | jwt = Just jwt }, Cmd.batch [ fetchPortfolio, fetchSymbols ] )

                        Models.AddCurrencyRoute symbol ->
                            ( { model | jwt = Just jwt }, Cmd.batch [ fetchPortfolio, fetchCurrency symbol ] )

                        Models.NotFoundRoute ->
                            ( { model | jwt = Just jwt }, newUrl portfolioPath )


currencyIsValid : Model -> Bool
currencyIsValid model =
    validateEmptyStringOrPositiveNumber model.inputCurrencyPrice
        == Nothing
        && validatePositiveNumber model.inputCurrencyAmount
        == Nothing


validateEmptyStringOrPositiveNumber : String -> Maybe String
validateEmptyStringOrPositiveNumber value =
    case value == "" of
        True ->
            Nothing

        False ->
            validatePositiveNumber value


validatePositiveNumber : String -> Maybe String
validatePositiveNumber value =
    case String.isEmpty value of
        True ->
            Just "Missing value"

        False ->
            case String.toFloat value of
                Ok amount ->
                    case amount > 0 of
                        True ->
                            Nothing

                        False ->
                            Just "Value must me possitive"

                Err e ->
                    Just "That is not a number"
