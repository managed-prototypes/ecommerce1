module Ui.TextStyle exposing
    ( body
    , button
    , header
    , headlineL
    , headlineS
    , headlineXL
    , subheader
    )

import Element exposing (..)
import Element.Font as Font


headlineXL : List (Attribute msg)
headlineXL =
    [ Font.size 152, Font.regular, Font.family [ Font.typeface "Inter", Font.sansSerif ] ]


headlineL : List (Attribute msg)
headlineL =
    [ Font.size 94, Font.regular, Font.family [ Font.typeface "Inter", Font.sansSerif ] ]


headlineS : List (Attribute msg)
headlineS =
    [ Font.size 36, Font.regular, Font.family [ Font.typeface "Inter", Font.sansSerif ] ]


header : List (Attribute msg)
header =
    [ Font.size 44, Font.medium, Font.family [ Font.typeface "Inter", Font.sansSerif ] ]


subheader : List (Attribute msg)
subheader =
    [ Font.size 32, Font.medium, Font.family [ Font.typeface "Inter", Font.sansSerif ] ]


button : List (Attribute msg)
button =
    [ Font.size 20, Font.medium, Font.family [ Font.typeface "Inter", Font.sansSerif ] ]


body : List (Attribute msg)
body =
    [ Font.size 20, Font.regular, Font.family [ Font.typeface "Inter", Font.sansSerif ] ]
