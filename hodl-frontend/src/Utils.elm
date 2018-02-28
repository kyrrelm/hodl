module Utils exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Models exposing (Coin, CurrencyOverview, CurrencyToSave, Model)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)


maybeYourBalance : Model -> String -> Maybe String
maybeYourBalance model symbol =
    case model.portfolio of
        RemoteData.Success portfolio ->
            let
                isCorrectCurrency currencyOverview =
                    currencyOverview.symbol == symbol
            in
            case List.head (List.filter isCorrectCurrency portfolio.currencies) of
                Nothing ->
                    Nothing

                Just currencyOverview ->
                    Just currencyOverview.balance

        _ ->
            Nothing


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
                span [ class "red" ] [ text percent, div [ class "icon-separator" ] [ text "%" ] ]

            else
                span [ class "green" ] [ text percent, div [ class "icon-separator" ] [ text "%" ] ]


dollarWithColor : String -> Html Msg
dollarWithColor amount =
    let
        firstCharMaybe =
            List.head (String.toList amount)
    in
    case firstCharMaybe of
        Nothing ->
            text ""

        Just firstChar ->
            if firstChar == '-' then
                span [ class "red" ] [ text amount, div [ class "icon-separator" ] [ text "$" ] ]

            else
                span [ class "green" ] [ text ("+" ++ amount), div [ class "icon-separator" ] [ text "$" ] ]
