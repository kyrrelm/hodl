module Players.PortfolioPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, style)
import Models exposing (Currency, Model, Portfolio)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)


view : Model -> Html Msg
view model =
    maybePortfolio model.portfolio


maybePortfolio : WebData Portfolio -> Html Msg
maybePortfolio response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success portfolio ->
            pageContainer portfolio

        RemoteData.Failure error ->
            text (toString error)


pageContainer : Portfolio -> Html Msg
pageContainer portfolio =
    div []
        [ nav portfolio
        , div [ class "container" ] [ portfolioContainer portfolio ]
        ]


nav : Portfolio -> Html Msg
nav portfolio =
    div [ class "nav white bg-black" ]
        [ div [ class "p2" ] [ text "Hodl" ]
        , div [ class "p2" ]
            [ span [] [ text ("$ " ++ portfolio.usdBalance) ]
            , span [ class "total-balance" ] [ text ("€ " ++ portfolio.eurBalance) ]
            ]
        ]


portfolioContainer : Portfolio -> Html Msg
portfolioContainer portfolio =
    div []
        [ div [ class "card-list-container" ] [ list portfolio.currencies ]
        ]


list : List Currency -> Html Msg
list currencies =
    div [ class "card-list" ] (List.map currencyCard currencies)


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



--    div []
--        [ div []
--            [ text currency.symbol
--            , text currency.balance
--            ]
--        ]
--editBtn : Currency -> Html.Html Msg
--editBtn player =
--    let
--        path =
--            playerPath player.id
--    in
--    a
--        [ class "btn regular"
--        , href path
--        ]
--        [ i [ class "fa fa-pencil mr1" ] [], text "Edit" ]
