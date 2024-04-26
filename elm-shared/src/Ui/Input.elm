module Ui.Input exposing
    ( new
    , view
    , withTestId
    )

import Common.E2e
import Element exposing (..)
import Element.Input as Input
import Maybe.Extra
import Ui.Constants as Constants



-- PUBLIC


new :
    { label : String
    , placeholder : String
    , text : String
    , onChange : String -> msg
    }
    -> Input msg
new args =
    { label = args.label
    , placeholder = args.placeholder
    , text = args.text
    , onChange = args.onChange
    , testId = Nothing
    }


withTestId : String -> Input msg -> Input msg
withTestId testId props =
    { props | testId = Just testId }


view : Input msg -> Element msg
view props =
    let
        commonStyles : List (Attr () msg)
        commonStyles =
            [ height (px 52)
            , Constants.roundBorder
            ]

        testIdAttributes : List (Attr () msg)
        testIdAttributes =
            Maybe.Extra.unwrap [] (Common.E2e.testId >> List.singleton) props.testId
    in
    Input.text
        (testIdAttributes ++ commonStyles)
        { onChange = props.onChange
        , text = props.text
        , placeholder = Just (Input.placeholder [] (text props.placeholder))
        , label = Input.labelAbove [] (text props.label)
        }



-- IMPLEMENTATION DETAILS


type alias Input msg =
    { label : String
    , placeholder : String
    , text : String
    , onChange : String -> msg

    -- Configurable props:
    , testId : Maybe String
    }
