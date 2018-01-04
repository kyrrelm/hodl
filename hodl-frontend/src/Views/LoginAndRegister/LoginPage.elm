module Views.LoginAndRegister.LoginPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode as Json
import Models exposing (Model)
import Msgs exposing (Msg)
import Views.LoginAndRegister.Common exposing (..)


view : Model -> Html Msg
view model =
    div [ class "login-container" ]
        [ div [ class "login-content" ]
            [ input
                [ class "h1 space-bottom"
                , type_ "text"
                , placeholder "email"
                , onInput Msgs.OnInputEmail
                ]
                []
            , div [ class "space-bottom" ]
                [ input
                    [ class "h1"
                    , type_ "password"
                    , placeholder "password"
                    , onInput Msgs.OnInputPassword
                    , onEnter Msgs.OnClickLogin
                    ]
                    []
                , inputLoginErrorView model.inputLoginError
                ]
            , button
                [ class "h1 space-bottom-small"
                , onClick Msgs.OnClickLogin
                ]
                [ text "Login" ]
            , button
                [ class "h1"
                , onClick Msgs.OnClickToRegisterPage
                ]
                [ text "Register" ]
            ]
        ]
