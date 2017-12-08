module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Models exposing (Currency, Symbol)
import Msgs exposing (Msg)
import RemoteData


fetchPortfolioRequest : Http.Request (List Currency)
fetchPortfolioRequest =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson portfolioDecoder
        , headers = [ Http.header "Authorization" "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1YTI0MWVlYzI5ZTQ5NTA2MjVkMDgzMTgiLCJyb2xlIjoidXNlciIsImlhdCI6MTUxMjMxNjY1MiwiZXhwIjoxNTEyOTIxNDUyfQ.PiD8hSU6oE_721l5hkh7ESJTXhQqpHUpXuyLUsy6GrQ" ]
        , method = "GET"
        , timeout = Nothing
        , url = fetchPlayersUrl
        , withCredentials = False
        }


fetchPlayers : Cmd Msg
fetchPlayers =
    fetchPortfolioRequest
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchPortfolio


fetchPlayersUrl : String
fetchPlayersUrl =
    "http://localhost:8080/portfolio/"


portfolioDecoder : Decode.Decoder (List Currency)
portfolioDecoder =
    Decode.list currencyDecoder


currencyDecoder : Decode.Decoder Currency
currencyDecoder =
    decode Currency
        |> required "symbol" Decode.string
        |> required "balance" Decode.string
        |> required "BTC" Decode.float
        |> required "ETH" Decode.float
        |> required "USD" Decode.float
        |> required "EUR" Decode.float



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


currencyEncoder : Currency -> Encode.Value
currencyEncoder currency =
    let
        attributes =
            [ ( "symbol", Encode.string currency.symbol )
            , ( "balance", Encode.string currency.balance )
            , ( "BTC", Encode.float currency.btc )
            , ( "ETH", Encode.float currency.eth )
            , ( "USD", Encode.float currency.usd )
            , ( "EUR", Encode.float currency.eur )
            ]
    in
    Encode.object attributes
