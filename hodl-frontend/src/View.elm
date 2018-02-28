module View exposing (..)

import Html exposing (Html, div, text)
import Models exposing (Model)
import Msgs exposing (Msg)
import Views.AddCurrencyPage
import Views.CurrencyPage
import Views.LoginAndRegister.LoginPage as LoginPage
import Views.LoginAndRegister.RegisterPage as RegisterPage
import Views.NewCurrencyPage
import Views.PortfolioPage


view : Model -> Html Msg
view model =
    page model


page : Model -> Html Msg
page model =
    case model.jwt of
        Nothing ->
            case model.route of
                Models.RegisterRoute ->
                    RegisterPage.view model

                _ ->
                    LoginPage.view model

        Just jwt ->
            case model.route of
                Models.RegisterRoute ->
                    RegisterPage.view model

                Models.LoginRoute ->
                    LoginPage.view model

                Models.PortfolioRoute ->
                    Views.PortfolioPage.view model

                Models.NewCurrencyRoute ->
                    Views.NewCurrencyPage.view model

                Models.AddCurrencyRoute symbol ->
                    Views.AddCurrencyPage.view model

                Models.CurrencyRoute symbol ->
                    Views.CurrencyPage.view model

                Models.NotFoundRoute ->
                    notFoundView


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
