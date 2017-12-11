module Views.NewCurrencyPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder)
import Html.Events exposing (onInput)
import Models exposing (Model, Symbol)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Views.NavBar exposing (view)


view : Model -> Html Msg
view model =
    div []
        [ Views.NavBar.view model
        , div [ class "container" ] [ maybeSymbols model ]
        ]


maybeSymbols : Model -> Html Msg
maybeSymbols model =
    case model.symbols of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success symbols ->
            symbolsContainer ( model.searchCoins, symbols )

        RemoteData.Failure error ->
            text (toString error)


symbolsContainer : ( String, List Symbol ) -> Html Msg
symbolsContainer ( searchCoins, symbols ) =
    div [ class "card-list-container" ] [ list ( searchCoins, symbols ) ]


list : ( String, List Symbol ) -> Html Msg
list ( searchCoins, symbols ) =
    let
        containsName symbol =
            String.contains (String.toLower searchCoins) (String.toLower symbol.name)

        containsSymbol symbol =
            String.contains (String.toLower searchCoins) (String.toLower symbol.symbol)

        filter symbol =
            containsName symbol || containsSymbol symbol

        filteredSymbols =
            List.filter filter symbols
    in
    div [ class "card-list" ]
        [ input [ class "search-input", placeholder "Find coin", onInput Msgs.OnSearchCoins ] []
        , div [] (List.map symbolCard filteredSymbols)
        ]


symbolCard : Symbol -> Html Msg
symbolCard symbol =
    div [ class "card" ]
        [ div [ class "card-symbol h3" ] [ text symbol.symbol ]
        , text symbol.name
        ]
