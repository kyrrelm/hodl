port module Ports exposing (..)

import Models exposing (Jwt)


port storeJwtToken : Jwt -> Cmd msg


port deleteJwtToken : () -> Cmd msg


port retrieveJwtToken : () -> Cmd msg


port receiveJwtToken : (Maybe Jwt -> msg) -> Sub msg
