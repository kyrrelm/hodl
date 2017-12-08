module Players.PortfolioPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, style)
import Models exposing (Currency, Model, Portfolio)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)


view : Model -> Html Msg
view model =
    div []
        [ nav
        , div [ class "card-list-container" ] [ maybeList model.portfolio ]
        ]


nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Hodl" ] ]


maybeList : WebData Portfolio -> Html Msg
maybeList response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success portfolio ->
            list portfolio.currencies

        RemoteData.Failure error ->
            text (toString error)


list : List Currency -> Html Msg
list portfolio =
    div [ class "card-list" ] (List.map portfolioCard portfolio)


portfolioCard : Currency -> Html Msg
portfolioCard currency =
    div [ class "card" ]
        [ div [ class "card-symbol h3" ] [ text currency.symbol ]
        , portfolioCardContent currency
        ]


portfolioCardContent : Currency -> Html Msg
portfolioCardContent currency =
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
