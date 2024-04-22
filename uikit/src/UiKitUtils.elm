module UiKitUtils exposing (deviceAwareContainer, smallGreyCaption, viewOnBothBackgrounds)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Ui.Color as Color
import Ui.Window exposing (ScreenClass(..))


{-| UI Kit laws don't apply to the UI Kit itself, right? 😅
-}
smallGreyCaption : List (Attribute msg)
smallGreyCaption =
    [ Font.size 14, Font.color Color.greyDimmed1 ]


deviceAwareContainer : ScreenClass -> List (Attribute msg) -> List (Element msg) -> Element msg
deviceAwareContainer screenClass =
    case screenClass of
        SmallScreen ->
            column

        BigScreen ->
            wrappedRow


viewOnBothBackgrounds : { title : String, screenClass : ScreenClass } -> List (Element msg) -> Element msg
viewOnBothBackgrounds { title, screenClass } elements =
    column [ width fill, Background.color Color.white ]
        [ el (paddingXY 50 20 :: smallGreyCaption) <| text title
        , deviceAwareContainer screenClass
            [ width fill ]
            [ column [ width fill, spacing 30, padding 50, Background.color Color.white, Font.color Color.black ] elements
            , column [ width fill, spacing 30, padding 50, Background.color Color.black, Font.color Color.white ] elements
            ]
        ]
