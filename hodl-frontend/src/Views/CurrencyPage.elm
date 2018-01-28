module Views.CurrencyPage exposing (..)

import Date
import Date.Extra.Config.Config_en_au exposing (config)
import Date.Extra.Format as Format exposing (format, formatUtc, isoMsecOffsetFormat)
import Html exposing (..)
import Html.Attributes exposing (alt, class, height, href, placeholder, src, style, width)
import Html.Events exposing (onClick)
import Models exposing (CurrencyOverview, Model, Transaction)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Views.NavBar exposing (view)


view : Model -> Html Msg
view model =
    div []
        [ Views.NavBar.view model
        , div [ class "container" ] [ maybeTransactions model.transactions ]
        ]


maybeTransactions : WebData (List Transaction) -> Html Msg
maybeTransactions response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success portfolio ->
            transactionsContainer portfolio

        RemoteData.Failure error ->
            text (toString error)


transactionsContainer : List Transaction -> Html Msg
transactionsContainer transactions =
    div []
        [ div [ class "card-list-container" ] [ list transactions ]
        ]


addCurrencyCard : Html Msg
addCurrencyCard =
    div [ class "card card-content-centered", onClick Msgs.OnClickNewCurrency ]
        [ div [ class "icon" ] [ img [ src "./assets/plus.svg" ] [] ]
        ]


list : List Transaction -> Html Msg
list transactions =
    div [ class "card-list" ]
        [ addCurrencyCard
        , div [] (List.map transactionCard transactions)
        ]


transactionCard : Transaction -> Html Msg
transactionCard transaction =
    div [ class "card" ]
        [ div [ class "card-symbol" ]
            [ div [ class "h3" ] [ text (displayString1 transaction.created) ]
            , div [ class "h3" ] [ text transaction.amount ]
            ]
        ]


displayString1 time =
    Result.withDefault "Failed to get a date." <|
        Result.map
            (format config config.format.dateTime)
            (Date.fromString time)


displayString2 =
    Result.withDefault "Failed to get a date." <|
        Result.map
            (formatUtc config isoMsecOffsetFormat)
            (Date.fromString "2015-06-01 12:45:14.211Z")
