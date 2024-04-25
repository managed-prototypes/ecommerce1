module Common.E2e exposing (testId)

import Element exposing (..)
import Html.Attributes


testId : String -> Attribute msg
testId =
    htmlAttribute << Html.Attributes.attribute "data-testid"
