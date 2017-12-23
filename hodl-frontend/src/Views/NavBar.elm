module Views.NavBar exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Models exposing (CurrencyOverview, Model, Portfolio)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)


view : Model -> Html Msg
view model =
    maybeNav model.portfolio


maybeNav : WebData Portfolio -> Html Msg
maybeNav response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success portfolio ->
            navBar portfolio

        RemoteData.Failure error ->
            text (toString error)


navBar : Portfolio -> Html Msg
navBar portfolio =
    div [ class "nav white bg-black" ]
        [ div [ class "p2 nav-name", onClick Msgs.OnClickNavBarName ] [ text "Hodl" ]
        , div [ class "p2" ]
            [ span [] [ text ("$ " ++ portfolio.usdBalance) ]
            , span [ class "total-balance" ] [ text ("฿ " ++ portfolio.eurBalance) ]
            ]
        ]
