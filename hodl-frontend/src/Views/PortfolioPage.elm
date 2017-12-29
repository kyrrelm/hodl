module Views.PortfolioPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, src, style)
import Html.Events exposing (onClick)
import Models exposing (CurrencyOverview, Model, Portfolio)
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
    div [ class "card", onClick Msgs.OnClickNewCurrency ]
        [ div [ class "card-content-centered icon" ] [ img [ src "./assets/plus.svg" ] [] ]
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
        [ div [ class "card-symbol h3" ] [ text (currency.name ++ " (" ++ currency.symbol ++ ")") ]
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
        , div [] [ text currency.balance ]
        , div [] [ text (currency.usdBalance ++ " $") ]
        , div [] [ text (currency.btcBalance ++ " ฿") ]
        ]


ratesContainer : CurrencyOverview -> Html Msg
ratesContainer currency =
    div [ class "container-right-align" ]
        [ div [ class "empty-line" ] []
        , percentWithColor currency.percentChange24h
        , div [] [ text (currency.usdPrice ++ " $") ]
        , div [] [ text (currency.btcPrice ++ " ฿") ]
        ]


percentWithColor : String -> Html Msg
percentWithColor percent =
    let
        firstCharMaybe =
            List.head (String.toList percent)
    in
    case firstCharMaybe of
        Nothing ->
            text ""

        Just firstChar ->
            if firstChar == '-' then
                div [ class "red" ] [ text (percent ++ " %") ]

            else
                div [ class "green" ] [ text (percent ++ " %") ]
