module Views.AddCurrencyPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder)
import Models exposing (Coin, Model)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Views.NavBar exposing (view)


view : Model -> Html Msg
view model =
    div []
        [ Views.NavBar.view model
        , div [ class "container" ] [ maybeCurrency model ]
        ]


maybeCurrency : Model -> Html Msg
maybeCurrency model =
    case model.currency of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success coins ->
            text "Derp"

        --            coinsContainer ( model.searchCoins, coins )
        RemoteData.Failure error ->
            text (toString error)



--coinsContainer : ( String, List Coin ) -> Html Msg
--coinsContainer ( searchCoins, coins ) =
--    div [ class "card-list-container" ] [ list ( searchCoins, coins ) ]
