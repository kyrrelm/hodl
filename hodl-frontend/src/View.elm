module View exposing (..)

import Html exposing (Html, div, text)
import Models exposing (Model)
import Msgs exposing (Msg)
import Views.AddCurrencyPage
import Views.LoginPage
import Views.NewCurrencyPage
import Views.PortfolioPage


view : Model -> Html Msg
view model =
    page model


page : Model -> Html Msg
page model =
    case model.jwt of
        Nothing ->
            Views.LoginPage.view model

        Just jwt ->
            case model.route of
                Models.LoginRoute ->
                    Views.LoginPage.view model

                Models.PortfolioRoute ->
                    Views.PortfolioPage.view model

                Models.CurrencyRoute ->
                    Views.NewCurrencyPage.view model

                Models.AddCurrencyRoute symbol ->
                    Views.AddCurrencyPage.view model

                Models.NotFoundRoute ->
                    notFoundView


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
