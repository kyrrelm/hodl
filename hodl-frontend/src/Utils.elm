module Utils exposing (..)

import Models exposing (Coin, CurrencyOverview, CurrencyToSave, Model)
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


precisionSubtract : String -> String -> Result String String
precisionSubtract a b =
    let
        aNoDot =
            String.filter (\c -> c /= '.') a ++ String.repeat (numberOfDecimals b) "0"

        bNoDot =
            String.filter (\c -> c /= '.') b ++ String.repeat (numberOfDecimals a) "0"

        totalNumberOfDecimals =
            numberOfDecimals a + numberOfDecimals b
    in
    case String.toInt aNoDot of
        Ok aInt ->
            case String.toInt bNoDot of
                Ok bInt ->
                    let
                        sumInt =
                            aInt - bInt
                    in
                    Ok (insertDot totalNumberOfDecimals (toString sumInt))

                Err e ->
                    Err e

        Err e ->
            Err e


insertDot : Int -> String -> String
insertDot numberOfDecimals string =
    let
        left =
            String.left (String.length string - numberOfDecimals) string

        right =
            String.right numberOfDecimals string
    in
    left ++ "." ++ right


numberOfDecimals : String -> Int
numberOfDecimals string =
    case List.head (String.indexes "." string) of
        Just index ->
            String.length string - index - 1

        Nothing ->
            0
