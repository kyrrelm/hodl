module Main exposing (..)

import Commands exposing (fetchCurrency, fetchPortfolio, fetchSymbols)
import Models exposing (Model, initialModel)
import Msgs exposing (Msg)
import Navigation exposing (Location)
import Routing
import Update exposing (update)
import View exposing (view)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.parseLocation location
    in
    case currentRoute of
        Models.LoginRoute ->
            ( initialModel currentRoute, Cmd.none )

        Models.PortfolioRoute ->
            ( initialModel currentRoute, Cmd.batch [ fetchPortfolio, fetchSymbols ] )

        Models.CurrencyRoute ->
            ( initialModel currentRoute, Cmd.batch [ fetchPortfolio, fetchSymbols ] )

        Models.AddCurrencyRoute symbol ->
            ( initialModel currentRoute, Cmd.batch [ fetchPortfolio, fetchCurrency symbol ] )

        Models.NotFoundRoute ->
            ( initialModel currentRoute, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Navigation.program Msgs.OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
