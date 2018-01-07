module Views.AddCurrencyPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (align, class, placeholder, type_)
import Html.Events exposing (onClick, onInput)
import Models exposing (Coin, CurrencyOverview, CurrencyToSave, Model)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Utils exposing (..)
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
            currencyContainer ( model, currency )

        RemoteData.Failure error ->
            text (toString error)


currencyContainer : ( Model, CurrencyToSave ) -> Html Msg
currencyContainer ( model, currency ) =
    div [ class "currencyContainer" ]
        [ div [ class "card-content h1 space-bottom" ] [ text currency.symbol ]
        , div [ class "card-content h2 space-bottom-small" ]
            [ div [] [ text "Current price" ]
            , div []
                [ div [] [ text ("$ " ++ currency.usd) ]
                ]
            ]
        , yourBalanceView model currency.symbol
        , setBalanceView model currency.symbol
        , div [ class "card-content space-bottom-small" ]
            [ div [ class "h2" ] [ text "Price (BTC)" ]
            , div []
                [ input [ class "h2 text-right input-field", type_ "text", placeholder "(optional) 0.00", onInput Msgs.OnInputCurrencyPrice ] []
                , inputCurrencyAmountErrorView model.inputCurrencyPriceError
                ]
            ]
        , div [ class "card-content space-bottom-large" ]
            [ div [ class "h2" ] [ text "Amount" ]
            , div []
                [ input [ class "h2 text-right input-field", type_ "text", placeholder "0.00", onInput Msgs.OnInputCurrencyAmount ] []
                , inputCurrencyAmountErrorView model.inputCurrencyAmountError
                ]
            ]
        , div [ class "align-right" ]
            [ button [ class "space-right", onClick Msgs.OnClickCurrencySave ] [ text "Save" ]
            , button [ onClick (Msgs.OnGoBack 1) ] [ text "Cancel" ]
            ]
        ]


yourBalanceView : Model -> String -> Html Msg
yourBalanceView model symbol =
    case maybeYourBalance model symbol of
        Nothing ->
            text ""

        Just balance ->
            div [ class "card-content h2 space-bottom-small" ]
                [ div [] [ text "Your balance" ]
                , div []
                    [ div [] [ text balance ]
                    ]
                ]


setBalanceView : Model -> String -> Html Msg
setBalanceView model symbol =
    case maybeYourBalance model symbol of
        Nothing ->
            text ""

        Just balance ->
            div [ class "card-content h2 space-bottom-small" ]
                [ div [] [ text "Set balance" ]
                , div []
                    [ label [ class "switch" ]
                        [ input [ type_ "checkbox", onClick Msgs.OnToggleSetBalance ] []
                        , span [ class "slider round" ] []
                        ]
                    ]
                ]


inputCurrencyAmountErrorView : Maybe String -> Html Msg
inputCurrencyAmountErrorView maybeError =
    case maybeError of
        Nothing ->
            text ""

        Just error ->
            div [ class "align-right" ] [ div [ class "validation-error" ] [ text error ] ]
