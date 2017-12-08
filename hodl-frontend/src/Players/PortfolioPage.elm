module Players.PortfolioPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, style)
import Html.Events exposing (onInput)
import Models exposing (Currency, Model)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)


view : Model -> Html Msg
view model =
    div []
        [ nav
        , input [ class "search-input", placeholder "Find coin", onInput Msgs.ChangeTest ] []
        , maybeList model.portfolio
        ]


nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Players" ] ]


maybeList : WebData (List Currency) -> Html Msg
maybeList response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success portfolio ->
            list portfolio

        RemoteData.Failure error ->
            text (toString error)


list : List Currency -> Html Msg
list portfolio =
    div [ class "p2" ] (List.map portfolioCard portfolio)


portfolioCard : Currency -> Html Msg
portfolioCard currency =
    div [ class "card" ]
        [ text currency.symbol
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
    let
        totalUsd =
            currency.balance * currency.usd
    in
    div []
        [ div [] [ text (toString currency.balance) ]
        ]


ratesContainer : Currency -> Html Msg
ratesContainer currency =
    div []
        [ div [] [ text ("USD: " ++ toString currency.usd) ]
        , div [] [ text ("EURO: " ++ toString currency.eur) ]
        , div [] [ text ("USD: " ++ toString currency.usd) ]
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
