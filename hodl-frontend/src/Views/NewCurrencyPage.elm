module Views.NewCurrencyPage exposing (..)

import Html exposing (..)
import Models exposing (Currency, Model, Portfolio)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Views.NavBar exposing (view)


view : Model -> Html Msg
view model =
    Views.NavBar.view model
