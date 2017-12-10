module Views.NewCurrencyPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Models exposing (Model, Symbol)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Views.NavBar exposing (view)


view : Model -> Html Msg
view model =
    div []
        [ Views.NavBar.view model
        , div [ class "container" ] [ maybeSymbols model.symbols ]
        ]


maybeSymbols : WebData (List Symbol) -> Html Msg
maybeSymbols response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success symbols ->
            symbolsContainer symbols

        RemoteData.Failure error ->
            text (toString error)


symbolsContainer : List Symbol -> Html Msg
symbolsContainer symbols =
    div [ class "card-list-container" ] [ list symbols ]


list : List Symbol -> Html Msg
list symbols =
    div [ class "card-list" ] (List.map symbolCard symbols)


symbolCard : Symbol -> Html Msg
symbolCard symbol =
    div [ class "card" ]
        [ div [ class "card-symbol h3" ] [ text symbol.symbol ]
        , text symbol.name
        ]
