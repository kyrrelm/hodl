module Utils exposing (..)

import Debug exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Models exposing (Coin, CurrencyOverview, CurrencyToSave, Model)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)


maybeYourBalance : Model -> String -> Maybe String
maybeYourBalance model symbol =
    case model.portfolio of
        RemoteData.NotAsked ->
            Nothing

        RemoteData.Loading ->
            Nothing

        RemoteData.Failure error ->
            Nothing

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
                span [ class "red" ] [ text percent, div [ style [ ( "display", "inline-block" ), ( "width", "1rem" ), ( "textAlign", "right" ) ] ] [ text "%" ] ]

            else
                span [ class "green" ] [ text percent, div [ style [ ( "display", "inline-block" ), ( "width", "1rem" ), ( "textAlign", "right" ) ] ] [ text "%" ] ]


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
                span [ class "red" ] [ text amount ]

            else
                span [ class "green" ] [ text ("+" ++ amount) ]
