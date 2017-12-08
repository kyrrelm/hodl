module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Models exposing (Currency, Portfolio, Symbol)
import Msgs exposing (Msg)
import RemoteData


fetchPortfolioRequest : Http.Request Portfolio
fetchPortfolioRequest =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson portfolioDecoder
        , headers = [ Http.header "Authorization" "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1YTI0MWVlYzI5ZTQ5NTA2MjVkMDgzMTgiLCJyb2xlIjoidXNlciIsImlhdCI6MTUxMjMxNjY1MiwiZXhwIjoxNTEyOTIxNDUyfQ.PiD8hSU6oE_721l5hkh7ESJTXhQqpHUpXuyLUsy6GrQ" ]
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


fetchPortfolioUrl : String
fetchPortfolioUrl =
    "http://localhost:8080/portfolio/"


portfolioDecoder : Decode.Decoder Portfolio
portfolioDecoder =
    decode
        Portfolio
        |> required "usdBalance" Decode.string
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



--savePlayerUrl : Symbol -> String
--savePlayerUrl playerId =
--    "http://localhost:4000/players/" ++ playerId
--
--
--savePlayerRequest : Currency -> Http.Request Currency
--savePlayerRequest player =
--    Http.request
--        { body =
--            currencyEncoder player |> Http.jsonBody
--        , expect = Http.expectJson playerDecoder
--        , headers = []
--        , method = "PATCH"
--        , timeout = Nothing
--        , url = savePlayerUrl player.id
--        , withCredentials = False
--        }
--
--
--savePlayerCmd : Currency -> Cmd Msg
--savePlayerCmd player =
--    savePlayerRequest player
--        |> Http.send Msgs.OnPlayerSave
--
--currencyEncoder : Currency -> Encode.Value
--currencyEncoder currency =
--    let
--        attributes =
--            [ ( "symbol", Encode.string currency.symbol )
--            , ( "balance", Encode.float currency.balance )
--            , ( "BTC", Encode.float currency.btc )
--            , ( "ETH", Encode.float currency.eth )
--            , ( "USD", Encode.float currency.usd )
--            , ( "EUR", Encode.float currency.eur )
--            ]
--    in
--    Encode.object attributes
