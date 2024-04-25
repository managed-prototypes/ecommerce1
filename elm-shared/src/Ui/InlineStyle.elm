module Ui.InlineStyle exposing (InlineStyle, render)

import Element exposing (..)
import Html.Attributes


type alias InlineStyle =
    List ( String, String )


{-| Render is allowed only once per element,
because elm-ui will override duplicate attributes
-}
render : List InlineStyle -> Attribute msg
render =
    List.concat
        >> List.map (\( k, v ) -> k ++ ": " ++ v ++ ";")
        >> String.concat
        >> Html.Attributes.attribute "style"
        >> htmlAttribute
