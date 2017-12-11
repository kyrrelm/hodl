module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Models exposing (Coin, Currency, Portfolio)
import Msgs exposing (Msg)
import RemoteData


fetchPortfolioUrl : String
fetchPortfolioUrl =
    "http://localhost:8080/portfolio/"


fetchPortfolioRequest : Http.Request Portfolio
fetchPortfolioRequest =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson portfolioDecoder
        , headers = [ Http.header "Authorization" "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1YTI0MWVlYzI5ZTQ5NTA2MjVkMDgzMTgiLCJyb2xlIjoidXNlciIsImlhdCI6MTUxMjkyOTM3MywiZXhwIjoxNTEzNTM0MTczfQ.9HHg11ZvvIgwqC1ISBp7_ZUr3_wPu1GFGj-_Ye-JMhI" ]
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
        |> required "eurBalance" Decode.string
        |> required "currencies" (Decode.list currencyDecoder)


currencyDecoder : Decode.Decoder Currency
currencyDecoder =
    decode
        Currency
        |> required "symbol" Decode.string
        |> required "balance" Decode.string
        |> required "usdBalance" Decode.string
        |> required "eurBalance" Decode.string
        |> required "BTC" Decode.string
        |> required "ETH" Decode.string
        |> required "USD" Decode.string
        |> required "EUR" Decode.string


fetchSymbolsUrl : String
fetchSymbolsUrl =
    "http://localhost:8080/currency/"


fetchSymbolsRequest : Http.Request (List Coin)
fetchSymbolsRequest =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson symbolsDecoder
        , headers = [ Http.header "Authorization" "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1YTI0MWVlYzI5ZTQ5NTA2MjVkMDgzMTgiLCJyb2xlIjoidXNlciIsImlhdCI6MTUxMjkyOTM3MywiZXhwIjoxNTEzNTM0MTczfQ.9HHg11ZvvIgwqC1ISBp7_ZUr3_wPu1GFGj-_Ye-JMhI" ]
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
