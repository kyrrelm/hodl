module Views.PortfolioPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (alt, class, height, href, placeholder, src, style, width)
import Html.Events exposing (onClick)
import Models exposing (CurrencyOverview, Model, Portfolio)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import String.Extra exposing (replace)
import Utils exposing (dollarWithColor, percentWithColor)
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
            [ div [ class "h3" ] [ text (currency.name ++ " (" ++ currency.symbol ++ ")") ]
            , div [ class "h3" ] [ text currency.balance ]
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
    div [ class "container-right-align", style [ ( "flexBasis", "8rem" ) ] ]
        [ div [ class "empty-line" ] []
        , div [] [ dollarWithColor currency.usdDiff24hAgo, div [ class "icon-separator" ] [ text "" ] ]
        , div [] [ text currency.usdBalance, div [ class "icon-separator" ] [ text "$" ] ]
        , div [] [ text currency.btcBalance, div [ class "icon-separator" ] [ text "฿" ] ]
        ]


ratesContainer : CurrencyOverview -> Html Msg
ratesContainer currency =
    div [ class "container-right-align" ]
        [ div [ class "empty-line" ] []
        , percentWithColor currency.percentChange24h
        , div [] [ text (currency.usdPrice ++ " $") ]
        , div [] [ text (currency.btcPrice ++ " ฿") ]
        ]
