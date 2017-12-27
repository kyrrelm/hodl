module View exposing (..)

import Html exposing (Html, div, text)
import Models exposing (Model)
import Msgs exposing (Msg)
import Views.AddCurrencyPage
import Views.LoginPage
import Views.NewCurrencyPage
import Views.PortfolioPage
import Views.RegisterPage


view : Model -> Html Msg
view model =
    page model


page : Model -> Html Msg
page model =
    case model.jwt of
        Nothing ->
            case model.route of
                Models.RegisterRoute ->
                    Views.RegisterPage.view model

                Models.LoginRoute ->
                    Views.LoginPage.view model

                Models.PortfolioRoute ->
                    Views.LoginPage.view model

                Models.CurrencyRoute ->
                    Views.LoginPage.view model

                Models.AddCurrencyRoute symbol ->
                    Views.LoginPage.view model

                Models.NotFoundRoute ->
                    Views.LoginPage.view model

        Just jwt ->
            case model.route of
                Models.RegisterRoute ->
                    Views.RegisterPage.view model

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
