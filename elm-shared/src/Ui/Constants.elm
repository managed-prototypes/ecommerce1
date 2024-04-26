module Ui.Constants exposing
    ( bigScreenStartsFrom
    , minimalSupportedMobileScreenWidth
    , roundBorder
    , sectionContentMaxWidthBigScreen
    , sectionContentMaxWidthSmallScreen
    )

import Element exposing (..)
import Element.Border as Border


roundBorder : Attribute msg
roundBorder =
    Border.rounded 1000


minimalSupportedMobileScreenWidth : Int
minimalSupportedMobileScreenWidth =
    360


bigScreenStartsFrom : Int
bigScreenStartsFrom =
    1280


{-| Includes minimal margins.
-}
sectionContentMaxWidthSmallScreen : Int
sectionContentMaxWidthSmallScreen =
    720


{-| Includes minimal margins.
-}
sectionContentMaxWidthBigScreen : Int
sectionContentMaxWidthBigScreen =
    1440
