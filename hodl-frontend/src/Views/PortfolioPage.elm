module Views.PortfolioPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, style)
import Html.Events exposing (onClick)
import Models exposing (Currency, Model, Portfolio)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Views.NavBar exposing (view)


view : Model -> Html Msg
view model =
    div []
        [ Views.NavBar.view model
        , div [ class "container" ] [ maybePortfolio model.portfolio ]
        ]


maybePortfolio : WebData Portfolio -> Html Msg
maybePortfolio response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success portfolio ->
            portfolioContainer portfolio

        RemoteData.Failure error ->
            text (toString error)


portfolioContainer : Portfolio -> Html Msg
portfolioContainer portfolio =
    div []
        [ div [ class "card-list-container" ] [ list portfolio.currencies ]
        ]


addCurrencyCard : Html Msg
addCurrencyCard =
    div [ class "card", onClick Msgs.OnNewCurrencyClick ]
        [ text "+"
        ]


list : List Currency -> Html Msg
list currencies =
    div [ class "card-list" ]
        [ addCurrencyCard
        , div [] (List.map currencyCard currencies)
        ]


currencyCard : Currency -> Html Msg
currencyCard currency =
    div [ class "card" ]
        [ div [ class "card-symbol h3" ] [ text currency.symbol ]
        , currencyCardContent currency
        ]


currencyCardContent : Currency -> Html Msg
currencyCardContent currency =
    div [ class "card-content" ]
        [ balanceContainer currency
        , ratesContainer currency
        ]


balanceContainer : Currency -> Html Msg
balanceContainer currency =
    div []
        [ div [] [ text currency.balance ]
        , div [ class "empty-line" ] []
        , div [] [ text ("$ " ++ currency.usdBalance) ]
        , div [] [ text ("€ " ++ currency.eurBalance) ]
        ]


ratesContainer : Currency -> Html Msg
ratesContainer currency =
    div []
        [ div [] [ text ("USD: " ++ currency.usd) ]
        , div [] [ text ("EUR: " ++ currency.eur) ]
        , div [] [ text ("BTC: " ++ currency.btc) ]
        , div [] [ text ("ETH: " ++ currency.eth) ]
        ]
