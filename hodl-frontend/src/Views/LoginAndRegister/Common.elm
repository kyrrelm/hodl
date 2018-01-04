module Views.LoginAndRegister.Common exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (keyCode, on)
import Json.Decode as Json
import Msgs exposing (Msg)


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


inputLoginErrorView : Maybe String -> Html Msg
inputLoginErrorView maybeError =
    case maybeError of
        Nothing ->
            text ""

        Just error ->
            div [ class "align-left" ] [ div [ class "validation-error" ] [ text error ] ]
