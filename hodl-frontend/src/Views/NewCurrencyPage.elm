module Views.NewCurrencyPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder)
import Html.Events exposing (onClick, onInput)
import Models exposing (Coin, Model)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Views.NavBar exposing (view)


view : Model -> Html Msg
view model =
    div []
        [ Views.NavBar.view model
        , div [ class "container" ] [ maybeCoins model ]
        ]


maybeCoins : Model -> Html Msg
maybeCoins model =
    case model.coins of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success coins ->
            coinsContainer ( model.inputSearchCoins, coins )

        RemoteData.Failure error ->
            text (toString error)


coinsContainer : ( String, List Coin ) -> Html Msg
coinsContainer ( inputSearchCoins, coins ) =
    div [ class "card-list-container" ] [ list ( inputSearchCoins, coins ) ]


list : ( String, List Coin ) -> Html Msg
list ( inputSearchCoins, coins ) =
    let
        containsName symbol =
            String.contains (String.toLower inputSearchCoins) (String.toLower symbol.name)

        containsSymbol symbol =
            String.contains (String.toLower inputSearchCoins) (String.toLower symbol.symbol)

        filter symbol =
            containsName symbol || containsSymbol symbol

        filteredCoins =
            List.filter filter coins
    in
    div [ class "card-list" ]
        [ input [ class "search-input", placeholder "Find coin", onInput Msgs.OnInputSearchCoin ] []
        , div [] (List.map symbolCard filteredCoins)
        ]


symbolCard : Coin -> Html Msg
symbolCard symbol =
    div [ class "card", onClick (Msgs.OnClickAddCurrency symbol.symbol) ]
        [ div [ class "card-symbol h3" ] [ text symbol.symbol ]
        , text symbol.name
        ]
