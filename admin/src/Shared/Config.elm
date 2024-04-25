module Shared.Config exposing (Config, configDecoder)

import Json.Decode


type alias Config =
    { graphqlUrl : String
    }


configDecoder : Json.Decode.Decoder Config
configDecoder =
    Json.Decode.map Config
        (Json.Decode.field "graphqlUrl" Json.Decode.string)
