module Views.PortfolioPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (alt, class, height, href, placeholder, src, style, width)
import Html.Events exposing (onClick)
import Models exposing (CurrencyOverview, Model, Portfolio)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Utils exposing (percentWithColor)
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
    div [ class "card card-content-centered", onClick Msgs.OnClickNewCurrency ]
        [ div [ class "icon" ] [ img [ src "./assets/plus.svg" ] [] ]
        ]


list : List CurrencyOverview -> Html Msg
list currencies =
    div [ class "card-list" ]
        [ addCurrencyCard
        , div [] (List.map currencyCard currencies)
        ]


currencyCard : CurrencyOverview -> Html Msg
currencyCard currency =
    div [ class "card", onClick (Msgs.OnClickAddCurrency currency.symbol) ]
        [ div [ class "card-symbol" ]
            [ img [ src ("https://files.coinmarketcap.com/static/img/coins/32x32/" ++ String.toLower currency.name ++ ".png"), alt "", height 32, width 32 ] []
            , div [ class "h3", style [ ( "alignSelf", "center" ), ( "marginLeft", "0.5rem" ) ] ] [ text (currency.name ++ " (" ++ currency.symbol ++ ")") ]
            ]
        , currencyCardContent currency
        ]


currencyCardContent : CurrencyOverview -> Html Msg
currencyCardContent currency =
    div [ class "card-content" ]
        [ balanceContainer currency
        , ratesContainer currency
        ]


balanceContainer : CurrencyOverview -> Html Msg
balanceContainer currency =
    div [ class "container-left-align", style [ ( "flexBasis", "8rem" ), ( "marginLeft", "2.5rem" ) ] ]
        [ div [ class "empty-line" ] []
        , div [] [ text currency.balance ]
        , div [] [ text ("$" ++ currency.usdBalance) ]
        , div [] [ text ("฿ " ++ currency.btcBalance) ]
        ]


ratesContainer : CurrencyOverview -> Html Msg
ratesContainer currency =
    div [ class "container-right-align" ]
        [ div [ class "empty-line" ] []
        , percentWithColor currency.percentChange24h
        , div [] [ text (currency.usdPrice ++ " $") ]
        , div [] [ text (currency.btcPrice ++ " ฿") ]
        ]
