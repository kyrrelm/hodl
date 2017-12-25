port module Ports exposing (..)

import Json.Encode exposing (Value)
import Models exposing (Jwt)



-- port for sending strings out to JavaScript


port storeJwtToken : Jwt -> Cmd msg


port retrieveJwtToken : () -> Cmd msg


port receiveJwtToken : (Jwt -> msg) -> Sub msg
