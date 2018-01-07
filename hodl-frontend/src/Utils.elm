module Utils exposing (..)

import Debug exposing (..)
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
