module Update exposing (..)

import Models exposing (Currency, Model)
import Msgs exposing (Msg)
import Navigation exposing (..)
import Routing exposing (newCurrencyPath, parseLocation)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnFetchPortfolio response ->
            ( { model | portfolio = response }, Cmd.none )

        Msgs.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
            ( { model | route = newRoute }, Cmd.none )

        Msgs.OnNewCurrencyClick ->
            ( model, newUrl newCurrencyPath )



--        Msgs.OnPlayerSave (Ok player) ->
--            ( updatePlayer model player, Cmd.none )
--
--        Msgs.OnPlayerSave (Err error) ->
--            ( model, Cmd.none )
--
--
--
--updatePlayer : Model -> Currency -> Model
--updatePlayer model updatedPlayer =
--    let
--        pick currentPlayer =
--            if updatedPlayer.id == currentPlayer.id then
--                updatedPlayer
--
--            else
--                currentPlayer
--
--        updatePlayerList players =
--            List.map pick players
--
--        updatedPlayers =
--            RemoteData.map updatePlayerList model.players
--    in
--    { model | players = updatedPlayers }
