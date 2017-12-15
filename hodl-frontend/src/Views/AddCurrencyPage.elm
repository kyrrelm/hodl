module Views.AddCurrencyPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (align, class, placeholder, type_)
import Html.Events exposing (onClick, onInput)
import Models exposing (Coin, Currency, Model)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Views.NavBar exposing (view)


view : Model -> Html Msg
view model =
    div []
        [ Views.NavBar.view model
        , div [ class "container-flex" ] [ maybeCurrency model ]
        ]


maybeCurrency : Model -> Html Msg
maybeCurrency model =
    case model.currency of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success currency ->
            currencyContainer currency

        RemoteData.Failure error ->
            text (toString error)


currencyContainer : Currency -> Html Msg
currencyContainer currency =
    div [ class "currencyContainer" ]
        [ div [ class "card-content h1 space-bottom" ] [ text currency.symbol ]
        , div [ class "card-content h2 space-bottom" ]
            [ div [] [ text "Current price" ]
            , div []
                [ div [] [ text ("$ " ++ currency.usd) ]
                , div [] [ text ("€ " ++ currency.eur) ]
                ]
            ]
        , div [ class "card-content h2 space-bottom" ]
            [ div [] [ text "Amount" ]
            , input [ class "h2 currency-input", type_ "text", placeholder "0.00", onInput Msgs.OnCurrencyAmountInput ] []
            ]
        , div [ class "align-right" ] [ button [ onClick Msgs.OnClickCurrencySave ] [ text "Save" ] ]
        ]
