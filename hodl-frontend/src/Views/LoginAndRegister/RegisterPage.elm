module Views.LoginAndRegister.RegisterPage exposing (..)

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
            , input
                [ class "h1 space-bottom"
                , type_ "password"
                , placeholder "password"
                , onInput Msgs.OnInputPassword
                ]
                []
            , div [ class "space-bottom" ]
                [ input
                    [ class "h1"
                    , type_ "password"
                    , placeholder "confirm password"
                    , onInput Msgs.OnInputPasswordRepeat
                    , onEnter Msgs.OnClickRegister
                    ]
                    []
                , inputLoginErrorView model.inputLoginError
                ]
            , button
                [ class "h1 space-bottom-small"
                , onClick Msgs.OnClickRegister
                ]
                [ text "Register" ]
            , button
                [ class "h1"
                , onClick Msgs.OnClickCancelRegister
                ]
                [ text "Cancel" ]
            ]
        ]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg

            else
                Json.fail "not ENTER"
    in
    on "keydown" (Json.andThen isEnter keyCode)
