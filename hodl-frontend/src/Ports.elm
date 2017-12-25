port module Ports exposing (..)

import Models exposing (Jwt)



-- port for sending strings out to JavaScript


port storeJwtToken : Jwt -> Cmd msg


port retrieveJwtToken : () -> Cmd msg


port receiveJwtToken : (Maybe Jwt -> msg) -> Sub msg
