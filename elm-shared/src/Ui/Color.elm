module Ui.Color exposing (..)

import Element exposing (..)


type alias RgbFloat0to1 =
    { red : Float, green : Float, blue : Float, alpha : Float }


toCssColor : Color -> String
toCssColor x =
    let
        rgbFloat : RgbFloat0to1
        rgbFloat =
            toRgb x

        colors : List String
        colors =
            [ rgbFloat.red, rgbFloat.green, rgbFloat.blue ]
                |> List.map ((*) 255 >> round >> String.fromInt)
    in
    "rgba("
        ++ String.join "," colors
        ++ ","
        ++ String.fromFloat rgbFloat.alpha
        ++ ")"



-- Colors to be used directly


black : Color
black =
    rgb255 0 0 0


blackDimmed : Color
blackDimmed =
    rgb255 26 26 26


grey : Color
grey =
    rgb255 82 82 82


greyDimmed1 : Color
greyDimmed1 =
    rgb255 140 140 140


greyDimmed2 : Color
greyDimmed2 =
    rgb255 232 232 232


greyDimmed3 : Color
greyDimmed3 =
    rgb255 242 242 242


white : Color
white =
    rgb255 255 255 255


dangerRed : Color
dangerRed =
    rgb255 250 70 22


primaryBlue : Color
primaryBlue =
    rgb255 0 87 255
