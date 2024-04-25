module Ui.Section exposing (withBackgroundColor)

import Element exposing (..)
import Element.Background as Background
import Ui.Constants


{-| Section only specifies paddingX.
The client code only sets the paddingY.
-}
withBackgroundColor : { backgroundColor : Color } -> Element msg -> Element msg
withBackgroundColor { backgroundColor } =
    withBackgroundAttrs
        { outerAttrs = [ Background.color backgroundColor ]
        }



-- IMPLEMENTATION DETAILS


withBackgroundAttrs : { outerAttrs : List (Attribute msg) } -> Element msg -> Element msg
withBackgroundAttrs { outerAttrs } content =
    let
        outerElement : List (Element msg) -> Element msg
        outerElement =
            column (width fill :: outerAttrs)

        innerElement : List (Element msg) -> Element msg
        innerElement =
            column [ width (fill |> maximum Ui.Constants.sectionContentMaxWidthBigScreen), paddingXY 112 0, centerX ]
    in
    outerElement [ innerElement [ content ] ]
