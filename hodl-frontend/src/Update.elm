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
                    ( { model | inputCurrencyPrice = "", inputCurrencyAmount = "", inputCurrencyAmountError = Nothing }, Cmd.batch [ newUrl (addCurrencyPath symbol), fetchCurrencyCmd jwt symbol ] )

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

                        RemoteData.Success currency ->
                            case currencyIsValid model of
                                True ->
                                    ( { model | currencyToSave = RemoteData.Loading }, saveCurrencyCmd jwt currency model.inputCurrencyAmount model.inputCurrencyPrice )

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
                    ( { model | currencyToSave = RemoteData.Failure error }, Cmd.none )

        Msgs.OnInputEmail input ->
            ( { model | inputEmail = input }, Cmd.none )

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
            ( { model | inputEmail = "", inputPassword = "", inputPasswordRepeat = "", inputLoginError = Nothing }, newUrl registerPath )

        Msgs.OnClickCancelRegister ->
            ( { model | inputEmail = "", inputPassword = "", inputPasswordRepeat = "", inputLoginError = Nothing }, newUrl loginPath )

        Msgs.OnLogin jwtResponse ->
            case jwtResponse of
                Ok jwt ->
                    ( { model | inputLoginError = Nothing }, storeJwtToken jwt )

                Err error ->
                    case maybeErrorMessage error of
                        Nothing ->
                            ( { model | inputLoginError = Just (toString error) }, Cmd.none )

                        Just body ->
                            ( { model | inputLoginError = Just body }, Cmd.none )

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

                        Models.CurrencyRoute ->
                            ( { model | jwt = Just jwt, inputEmail = "", inputPassword = "", inputPasswordRepeat = "" }, Cmd.batch [ fetchPortfolioCmd jwt, fetchSymbolsCmd jwt ] )

                        Models.AddCurrencyRoute symbol ->
                            ( { model | jwt = Just jwt, inputEmail = "", inputPassword = "", inputPasswordRepeat = "" }, Cmd.batch [ fetchPortfolioCmd jwt, fetchCurrencyCmd jwt symbol ] )

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


isAuthorized : WebData a -> Bool
isAuthorized response =
    case response of
        RemoteData.NotAsked ->
            True

        RemoteData.Loading ->
            True

        RemoteData.Success portfolio ->
            True

        RemoteData.Failure error ->
            not (isUnauthorizedError error)


isUnauthorizedError : Http.Error -> Bool
isUnauthorizedError error =
    case error of
        BadUrl string ->
            False

        Timeout ->
            False

        NetworkError ->
            False

        BadStatus responseError ->
            if responseError.status.code == 401 then
                True

            else
                False

        BadPayload toString a ->
            False


maybeErrorMessage : Http.Error -> Maybe String
maybeErrorMessage error =
    case error of
        BadUrl string ->
            Nothing

        Timeout ->
            Nothing

        NetworkError ->
            Nothing

        BadStatus responseError ->
            if responseError.status.code == 400 || responseError.status.code == 409 then
                case Decode.decodeString (field "error" string) responseError.body of
                    Err e ->
                        Just "Noe gikk galt i kontakten med serveren"

                    Ok errorText ->
                        Just errorText

            else
                Nothing

        BadPayload toString a ->
            Nothing
