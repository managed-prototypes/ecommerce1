module UiKitUtils exposing (smallGreyCaption, viewOnBothBackgrounds)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Ui.Color as Color


{-| UI Kit laws don't apply to the UI Kit itself, right? 😅
-}
smallGreyCaption : List (Attribute msg)
smallGreyCaption =
    [ Font.size 14, Font.color Color.greyDimmed1 ]


viewOnBothBackgrounds : { title : String } -> List (Element msg) -> Element msg
viewOnBothBackgrounds { title } elements =
    column [ width fill, Background.color Color.white ]
        [ el (paddingXY 50 20 :: smallGreyCaption) <| text title
        , wrappedRow
            [ width fill ]
            [ column [ width fill, spacing 30, padding 50, Background.color Color.white, Font.color Color.black ] elements
            , column [ width fill, spacing 30, padding 50, Background.color Color.black, Font.color Color.white ] elements
            ]
        ]
