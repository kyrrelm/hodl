module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Models exposing (Coin, Currency, CurrencyBalance, CurrencyOverview, Portfolio)
import Msgs exposing (Msg)
import RemoteData


jwtToken =
    "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1YTNlZDRlOGMwZTI5ZDA5MzY2NTRlMmMiLCJyb2xlIjoidXNlciIsImlhdCI6MTUxNDA2NzE3NiwiZXhwIjoxNTE0NjcxOTc2fQ.9oYblPQkBESX0fCTbKPpCcCPyxpuuWgWJli0tbbVcys"


fetchPortfolioUrl : String
fetchPortfolioUrl =
    "http://localhost:8080/portfolio/"


fetchPortfolioRequest : Http.Request Portfolio
fetchPortfolioRequest =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson portfolioDecoder
        , headers = [ Http.header "Authorization" jwtToken ]
        , method = "GET"
        , timeout = Nothing
        , url = fetchPortfolioUrl
        , withCredentials = False
        }


fetchPortfolio : Cmd Msg
fetchPortfolio =
    fetchPortfolioRequest
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchPortfolio


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
        |> required "balance" Decode.string
        |> required "usdBalance" Decode.string
        |> required "btcBalance" Decode.string
        |> required "price_usd" Decode.string
        |> required "price_btc" Decode.string


fetchSymbolsUrl : String
fetchSymbolsUrl =
    "http://localhost:8080/currency/"


fetchSymbolsRequest : Http.Request (List Coin)
fetchSymbolsRequest =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson symbolsDecoder
        , headers = [ Http.header "Authorization" jwtToken ]
        , method = "GET"
        , timeout = Nothing
        , url = fetchSymbolsUrl
        , withCredentials = False
        }


fetchSymbols : Cmd Msg
fetchSymbols =
    fetchSymbolsRequest
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchSymbols


symbolsDecoder : Decode.Decoder (List Coin)
symbolsDecoder =
    Decode.list symbolDecoder


symbolDecoder : Decode.Decoder Coin
symbolDecoder =
    decode
        Coin
        |> required "symbol" Decode.string
        |> required "name" Decode.string


fetchCurrencyUrl : String -> String
fetchCurrencyUrl symbol =
    "http://localhost:8080/currency/rates?symbols=" ++ symbol


fetchCurrencyRequest : String -> Http.Request Currency
fetchCurrencyRequest symbol =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson currencyDecoder
        , headers = [ Http.header "Authorization" jwtToken ]
        , method = "GET"
        , timeout = Nothing
        , url = fetchCurrencyUrl symbol
        , withCredentials = False
        }


fetchCurrency : String -> Cmd Msg
fetchCurrency symbol =
    fetchCurrencyRequest symbol
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchCurrency


currencyDecoder : Decode.Decoder Currency
currencyDecoder =
    decode
        Currency
        |> required "symbol" Decode.string
        |> required "price_btc" Decode.string
        |> required "price_usd" Decode.string


saveCurrencyUrl : String
saveCurrencyUrl =
    "http://localhost:8080/portfolio/"


saveCurrencyRequest : ( Currency, String, String ) -> Http.Request CurrencyBalance
saveCurrencyRequest ( currency, amount, btcPrice ) =
    Http.request
        { body =
            currencyEncoder ( currency, amount, btcPrice ) |> Http.jsonBody
        , expect = Http.expectJson portfolioEntryDecoder
        , headers = [ Http.header "Authorization" jwtToken ]
        , method = "POST"
        , timeout = Nothing
        , url = saveCurrencyUrl
        , withCredentials = False
        }


portfolioEntryDecoder : Decode.Decoder CurrencyBalance
portfolioEntryDecoder =
    decode CurrencyBalance
        |> required "symbol" Decode.string
        |> required "balance" Decode.string


saveCurrencyCmd : ( Currency, String, String ) -> Cmd Msg
saveCurrencyCmd ( currency, amount, priceBtc ) =
    saveCurrencyRequest ( currency, amount, priceBtc )
        |> Http.send Msgs.OnCurrencySave


currencyEncoder : ( Currency, String, String ) -> Encode.Value
currencyEncoder ( currency, amount, priceBtc ) =
    let
        attributes =
            [ ( "symbol", Encode.string currency.symbol )
            , ( "amount", Encode.string amount )
            , ( "price_btc", Encode.string priceBtc )
            ]
    in
    Encode.object attributes
