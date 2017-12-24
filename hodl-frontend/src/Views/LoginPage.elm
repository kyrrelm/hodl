module Views.LoginPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_)
import Models exposing (Model)
import Msgs exposing (Msg)


view : Model -> Html Msg
view model =
    div [ class "login-container" ]
        [ div [ class "login-content" ]
            [ input [ class "h1 space-bottom", type_ "text", placeholder "email" ] []
            , input [ class "h1 space-bottom", type_ "text", placeholder "password" ] []
            , button [ class "h1 space-bottom-small" ] [ text "Login" ]
            , button [ class "h1" ] [ text "Register" ]
            ]
        ]
