module Players.PortfolioPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder)
import Html.Events exposing (onInput)
import Models exposing (Currency, Model)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Routing exposing (playerPath)


view : Model -> Html Msg
view model =
    div []
        [ nav
        , input [ placeholder "Text to reverse", onInput Msgs.ChangeTest ] []
        , text model.test
        , maybeList model.portfolio
        ]


nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Players" ] ]


maybeList : WebData (List Currency) -> Html Msg
maybeList response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success portfolio ->
            list portfolio

        RemoteData.Failure error ->
            text (toString error)


list : List Currency -> Html Msg
list portfolio =
    div [ class "p2" ] (List.map portfolioRow portfolio)


portfolioRow : Currency -> Html Msg
portfolioRow currency =
    text currency.symbol



--    div []
--        [ div []
--            [ text currency.symbol
--            , text currency.balance
--            ]
--        ]
--editBtn : Currency -> Html.Html Msg
--editBtn player =
--    let
--        path =
--            playerPath player.id
--    in
--    a
--        [ class "btn regular"
--        , href path
--        ]
--        [ i [ class "fa fa-pencil mr1" ] [], text "Edit" ]
