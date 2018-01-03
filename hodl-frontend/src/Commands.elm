module Commands exposing (..)

import Http exposing (Header)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Models exposing (Coin, CurrencyBalance, CurrencyOverview, CurrencyToSave, Jwt, Portfolio)
import Msgs exposing (Msg)
import RemoteData


apiKey =
    "123"


baseUrl =
    "http://localhost:8080/"



--baseUrl =
--    "https://hodl-moe.herokuapp.com/"


commonHeaders : Jwt -> List Header
commonHeaders jwt =
    [ Http.header "Authorization" (jwtHeader jwt), Http.header "api-key" apiKey ]


jwtHeader : Jwt -> String
jwtHeader jwt =
    "Bearer " ++ jwt.token


fetchPortfolioCmd : Jwt -> Cmd Msg
fetchPortfolioCmd jwt =
    fetchPortfolioRequest jwt
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchPortfolio


fetchPortfolioRequest : Jwt -> Http.Request Portfolio
fetchPortfolioRequest jwt =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson portfolioDecoder
        , headers = commonHeaders jwt
        , method = "GET"
        , timeout = Nothing
        , url = fetchPortfolioUrl
        , withCredentials = False
        }


fetchPortfolioUrl : String
fetchPortfolioUrl =
    baseUrl ++ "portfolio/"


portfolioDecoder : Decode.Decoder Portfolio
portfolioDecoder =
    decode
        Portfolio
        |> required "usdBalance" Decode.string
        |> required "btcBalance" Decode.string
        |> required "currencies" (Decode.list currencyBalanceDecoder)


currencyBalanceDecoder : Decode.Decoder CurrencyOverview
currencyBalanceDecoder =
    decode
        CurrencyOverview
        |> required "symbol" Decode.string
        |> required "name" Decode.string
        |> required "balance" Decode.string
        |> required "usdBalance" Decode.string
        |> required "btcBalance" Decode.string
        |> required "price_usd" Decode.string
        |> required "price_btc" Decode.string
        |> required "percent_change_24h" Decode.string


fetchSymbolsCmd : Jwt -> Cmd Msg
fetchSymbolsCmd jwt =
    fetchSymbolsRequest jwt
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchSymbols


fetchSymbolsRequest : Jwt -> Http.Request (List Coin)
fetchSymbolsRequest jwt =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson symbolsDecoder
        , headers = commonHeaders jwt
        , method = "GET"
        , timeout = Nothing
        , url = fetchSymbolsUrl
        , withCredentials = False
        }


fetchSymbolsUrl : String
fetchSymbolsUrl =
    baseUrl ++ "currency/"


symbolsDecoder : Decode.Decoder (List Coin)
symbolsDecoder =
    Decode.list symbolDecoder


symbolDecoder : Decode.Decoder Coin
symbolDecoder =
    decode
        Coin
        |> required "symbol" Decode.string
        |> required "name" Decode.string


fetchCurrencyCmd : Jwt -> String -> Cmd Msg
fetchCurrencyCmd jwt symbol =
    fetchCurrencyRequest jwt symbol
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchCurrency


fetchCurrencyRequest : Jwt -> String -> Http.Request CurrencyToSave
fetchCurrencyRequest jwt symbol =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson currencyDecoder
        , headers = commonHeaders jwt
        , method = "GET"
        , timeout = Nothing
        , url = fetchCurrencyUrl symbol
        , withCredentials = False
        }


fetchCurrencyUrl : String -> String
fetchCurrencyUrl symbol =
    baseUrl ++ "currency/rates?symbols=" ++ symbol


currencyDecoder : Decode.Decoder CurrencyToSave
currencyDecoder =
    decode
        CurrencyToSave
        |> required "symbol" Decode.string
        |> required "price_btc" Decode.string
        |> required "price_usd" Decode.string


saveCurrencyCmd : Jwt -> CurrencyToSave -> String -> String -> Cmd Msg
saveCurrencyCmd jwt currency amount priceBtc =
    saveCurrencyRequest jwt currency amount priceBtc
        |> Http.send Msgs.OnCurrencySave


saveCurrencyRequest : Jwt -> CurrencyToSave -> String -> String -> Http.Request CurrencyBalance
saveCurrencyRequest jwt currency amount btcPrice =
    Http.request
        { body =
            currencyEncoder ( currency, amount, btcPrice ) |> Http.jsonBody
        , expect = Http.expectJson portfolioEntryDecoder
        , headers = commonHeaders jwt
        , method = "POST"
        , timeout = Nothing
        , url = saveCurrencyUrl
        , withCredentials = False
        }


saveCurrencyUrl : String
saveCurrencyUrl =
    baseUrl ++ "portfolio/"


portfolioEntryDecoder : Decode.Decoder CurrencyBalance
portfolioEntryDecoder =
    decode CurrencyBalance
        |> required "symbol" Decode.string
        |> required "balance" Decode.string


currencyEncoder : ( CurrencyToSave, String, String ) -> Encode.Value
currencyEncoder ( currency, amount, priceBtc ) =
    let
        attributes =
            [ ( "symbol", Encode.string currency.symbol )
            , ( "amount", Encode.string amount )
            , ( "price_btc", Encode.string priceBtc )
            ]
    in
    Encode.object attributes


loginCmd : ( String, String ) -> Cmd Msg
loginCmd ( email, password ) =
    loginRequest ( email, password )
        |> Http.send Msgs.OnLogin


loginRequest : ( String, String ) -> Http.Request Jwt
loginRequest ( email, password ) =
    Http.request
        { body =
            loginEncoder ( email, password ) |> Http.jsonBody
        , expect = Http.expectJson loginDecoder
        , headers = [ Http.header "api-key" apiKey ]
        , method = "POST"
        , timeout = Nothing
        , url = loginUrl
        , withCredentials = False
        }


loginUrl : String
loginUrl =
    baseUrl ++ "auth"


loginEncoder : ( String, String ) -> Encode.Value
loginEncoder ( email, password ) =
    let
        attributes =
            [ ( "email", Encode.string email )
            , ( "password", Encode.string password )
            ]
    in
    Encode.object attributes


loginDecoder : Decode.Decoder Jwt
loginDecoder =
    decode Jwt
        |> required "token" Decode.string


registerCmd : ( String, String ) -> Cmd Msg
registerCmd ( email, password ) =
    registerRequest ( email, password )
        |> Http.send Msgs.OnLogin


registerRequest : ( String, String ) -> Http.Request Jwt
registerRequest ( email, password ) =
    Http.request
        { body =
            loginEncoder ( email, password ) |> Http.jsonBody
        , expect = Http.expectJson loginDecoder
        , headers = [ Http.header "api-key" apiKey ]
        , method = "POST"
        , timeout = Nothing
        , url = registerUrl
        , withCredentials = False
        }


registerUrl : String
registerUrl =
    baseUrl ++ "auth/register"
