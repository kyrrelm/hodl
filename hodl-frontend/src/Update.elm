module Update exposing (..)

import Commands exposing (..)
import Http exposing (Error(..))
import Json.Decode as Decode exposing (decodeString, field, string)
import Models exposing (CurrencyOverview, Jwt, Model, Route)
import Msgs exposing (Msg)
import Navigation exposing (..)
import Ports exposing (..)
import RemoteData exposing (WebData)
import Result exposing (Result)
import Routing exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnFetchPortfolio response ->
            case isAuthorized response of
                True ->
                    ( { model | portfolio = response }, Cmd.none )

                False ->
                    ( { model | portfolio = response, jwt = Nothing }, newUrl loginPath )

        Msgs.OnFetchTransactions response ->
            case isAuthorized response of
                True ->
                    ( { model | transactions = response }, Cmd.none )

                False ->
                    ( { model | transactions = response, jwt = Nothing }, newUrl loginPath )

        Msgs.OnFetchSymbols response ->
            case isAuthorized response of
                True ->
                    ( { model | coins = response }, Cmd.none )

                False ->
                    ( { model | coins = response, jwt = Nothing }, newUrl loginPath )

        Msgs.OnFetchCurrency response ->
            case isAuthorized response of
                True ->
                    ( { model | currency = response }, Cmd.none )

                False ->
                    ( { model | currency = response, jwt = Nothing }, newUrl loginPath )

        Msgs.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
            ( { model | route = newRoute }, Cmd.none )

        Msgs.OnGoBack amount ->
            ( model, back amount )

        Msgs.OnClickNewCurrency ->
            case model.jwt of
                Nothing ->
                    ( model, newUrl loginPath )

                Just jwt ->
                    ( { model | inputSearchCoins = "" }, Cmd.batch [ newUrl newCurrencyPath, fetchSymbolsCmd jwt ] )

        Msgs.OnClickNavBarName ->
            case model.jwt of
                Nothing ->
                    ( model, newUrl loginPath )

                Just jwt ->
                    ( model, Cmd.batch [ newUrl portfolioPath, fetchPortfolioCmd jwt ] )

        Msgs.OnClickAddCurrency symbol ->
            case model.jwt of
                Nothing ->
                    ( model, newUrl loginPath )

                Just jwt ->
                    ( { model
                        | inputCurrencyPrice = ""
                        , inputCurrencyPriceError = Nothing
                        , inputCurrencyAmount = ""
                        , inputCurrencyAmountError = Nothing
                        , shouldSetBalance = False
                      }
                    , Cmd.batch [ newUrl (addCurrencyPath symbol), fetchCurrencyCmd jwt symbol, fetchPortfolioCmd jwt ]
                    )

        Msgs.OnInputSearchCoin input ->
            ( { model | inputSearchCoins = input }, Cmd.none )

        Msgs.OnInputCurrencyPrice input ->
            ( { model | inputCurrencyPrice = input, inputCurrencyPriceError = Nothing }, Cmd.none )

        Msgs.OnInputCurrencyAmount input ->
            ( { model | inputCurrencyAmount = input, inputCurrencyAmountError = Nothing }, Cmd.none )

        Msgs.OnClickCurrencySave ->
            case model.jwt of
                Nothing ->
                    ( model, newUrl loginPath )

                Just jwt ->
                    case model.currency of
                        RemoteData.NotAsked ->
                            ( model, Cmd.none )

                        RemoteData.Loading ->
                            ( model, Cmd.none )

                        RemoteData.Failure error ->
                            ( model, Cmd.none )

                        RemoteData.Success currency ->
                            case model.shouldSetBalance of
                                True ->
                                    case currencyIsValid model of
                                        True ->
                                            ( { model | currencyToSave = RemoteData.Loading }, saveCurrencyCmd jwt currency model.inputCurrencyAmount model.inputCurrencyPrice model.shouldSetBalance )

                                        False ->
                                            ( { model
                                                | inputCurrencyAmountError =
                                                    validatePositiveNumber model.inputCurrencyAmount
                                                , inputCurrencyPriceError =
                                                    validateEmptyStringOrPositiveNumber model.inputCurrencyPrice
                                              }
                                            , Cmd.none
                                            )

                                False ->
                                    case currencyIsValid model of
                                        True ->
                                            ( { model | currencyToSave = RemoteData.Loading }, saveCurrencyCmd jwt currency model.inputCurrencyAmount model.inputCurrencyPrice model.shouldSetBalance )

                                        False ->
                                            ( { model
                                                | inputCurrencyAmountError =
                                                    validateNumber model.inputCurrencyAmount
                                                , inputCurrencyPriceError =
                                                    validateEmptyStringOrPositiveNumber model.inputCurrencyPrice
                                              }
                                            , Cmd.none
                                            )

        Msgs.OnCurrencySave (Ok portfolioEntry) ->
            case model.jwt of
                Nothing ->
                    ( model, newUrl loginPath )

                Just jwt ->
                    ( { model | currencyToSave = RemoteData.Success portfolioEntry }, Cmd.batch [ newUrl portfolioPath, fetchPortfolioCmd jwt ] )

        Msgs.OnCurrencySave (Err error) ->
            case isUnauthorizedError error of
                True ->
                    ( { model | jwt = Nothing }, newUrl loginPath )

                False ->
                    ( { model | currencyToSave = RemoteData.Failure error, inputCurrencyAmountError = Just (errorMessage error) }, Cmd.none )

        Msgs.OnInputEmail input ->
            ( { model | inputEmail = String.toLower input }, Cmd.none )

        Msgs.OnInputPassword input ->
            ( { model | inputPassword = input }, Cmd.none )

        Msgs.OnInputPasswordRepeat input ->
            ( { model | inputPasswordRepeat = input }, Cmd.none )

        Msgs.OnClickLogin ->
            ( model, loginCmd ( model.inputEmail, model.inputPassword ) )

        Msgs.OnClickLogout ->
            ( { model | jwt = Nothing }, deleteJwtToken () )

        Msgs.OnClickRegister ->
            case validatePassword model of
                Nothing ->
                    ( model, registerCmd ( model.inputEmail, model.inputPassword ) )

                Just error ->
                    ( { model | inputLoginError = Just error }, Cmd.none )

        Msgs.OnClickToRegisterPage ->
            ( { model | inputPassword = "", inputPasswordRepeat = "", inputLoginError = Nothing }, newUrl registerPath )

        Msgs.OnClickCancelRegister ->
            ( { model | inputPassword = "", inputPasswordRepeat = "", inputLoginError = Nothing }, newUrl loginPath )

        Msgs.OnToggleSetBalance ->
            ( { model | shouldSetBalance = not model.shouldSetBalance }, Cmd.none )

        Msgs.OnLogin jwtResponse ->
            case jwtResponse of
                Ok jwt ->
                    ( { model | inputLoginError = Nothing }, storeJwtToken jwt )

                Err error ->
                    ( { model | inputLoginError = Just (errorMessage error) }, Cmd.none )

        Msgs.ReceiveJwtToken maybeJwt ->
            case maybeJwt of
                Nothing ->
                    ( model, Cmd.none )

                Just jwt ->
                    case model.route of
                        Models.LoginRoute ->
                            ( { model | jwt = Just jwt, inputEmail = "", inputPassword = "", inputPasswordRepeat = "" }, Cmd.batch [ fetchPortfolioCmd jwt, fetchSymbolsCmd jwt, newUrl portfolioPath ] )

                        Models.RegisterRoute ->
                            ( { model | jwt = Just jwt, inputEmail = "", inputPassword = "", inputPasswordRepeat = "" }, Cmd.batch [ fetchPortfolioCmd jwt, fetchSymbolsCmd jwt, newUrl portfolioPath ] )

                        Models.PortfolioRoute ->
                            ( { model | jwt = Just jwt, inputEmail = "", inputPassword = "", inputPasswordRepeat = "" }, Cmd.batch [ fetchPortfolioCmd jwt, fetchSymbolsCmd jwt ] )

                        Models.NewCurrencyRoute ->
                            ( { model | jwt = Just jwt, inputEmail = "", inputPassword = "", inputPasswordRepeat = "" }, Cmd.batch [ fetchPortfolioCmd jwt, fetchSymbolsCmd jwt ] )

                        Models.AddCurrencyRoute symbol ->
                            ( { model | jwt = Just jwt, inputEmail = "", inputPassword = "", inputPasswordRepeat = "" }, Cmd.batch [ fetchPortfolioCmd jwt, fetchCurrencyCmd jwt symbol ] )

                        Models.CurrencyRoute symbol ->
                            ( { model | jwt = Just jwt }, Cmd.batch [ fetchPortfolioCmd jwt, fetchTransactionsCmd jwt symbol ] )

                        Models.NotFoundRoute ->
                            ( { model | jwt = Just jwt, inputEmail = "", inputPassword = "", inputPasswordRepeat = "" }, newUrl portfolioPath )


validatePassword : Model -> Maybe String
validatePassword model =
    if String.length model.inputPassword < 10 then
        Just "Password must be at least 10 characters"

    else if model.inputPassword /= model.inputPasswordRepeat then
        Just "Passwords must match"

    else
        Nothing


currencyIsValid : Model -> Bool
currencyIsValid model =
    validateEmptyStringOrPositiveNumber model.inputCurrencyPrice
        == Nothing
        && validateNumber model.inputCurrencyAmount
        == Nothing
        && (not model.shouldSetBalance || validatePositiveNumber model.inputCurrencyAmount == Nothing)


validateEmptyStringOrPositiveNumber : String -> Maybe String
validateEmptyStringOrPositiveNumber value =
    case value == "" of
        True ->
            Nothing

        False ->
            validatePositiveNumber value


validateNumber : String -> Maybe String
validateNumber value =
    case String.isEmpty value of
        True ->
            Just "Missing value"

        False ->
            case String.toFloat value of
                Ok amount ->
                    Nothing

                Err e ->
                    Just "That is not a number"


validatePositiveNumber : String -> Maybe String
validatePositiveNumber value =
    case String.isEmpty value of
        True ->
            Just "Missing value"

        False ->
            case String.toFloat value of
                Ok amount ->
                    case amount >= 0 of
                        True ->
                            Nothing

                        False ->
                            Just "Value must me possitive"

                Err e ->
                    Just "That is not a number"


isAuthorized : WebData a -> Bool
isAuthorized response =
    case response of
        RemoteData.Failure error ->
            not (isUnauthorizedError error)

        _ ->
            True


isUnauthorizedError : Http.Error -> Bool
isUnauthorizedError error =
    case error of
        BadStatus responseError ->
            responseError.status.code == 401

        _ ->
            False


errorMessage : Http.Error -> String
errorMessage error =
    let
        standardError =
            "Noe gikk galt i kontakten med serveren"
    in
    case error of
        BadUrl string ->
            standardError

        Timeout ->
            standardError

        NetworkError ->
            standardError

        BadStatus responseError ->
            if responseError.status.code == 400 || responseError.status.code == 409 then
                case Decode.decodeString (field "error" string) responseError.body of
                    Err e ->
                        standardError

                    Ok errorText ->
                        errorText

            else
                standardError

        BadPayload toString a ->
            standardError
