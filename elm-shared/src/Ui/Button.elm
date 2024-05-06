module Ui.Button exposing
    ( new
    , view
    , withStatesFrom
    , withStyleDangerOnBlack
    , withStyleDangerOnWhite
    , withStyleWhiteOnBlack
    , withTestId
    )

import Common.E2e
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes
import Maybe.Extra
import RemoteData exposing (RemoteData)
import Ui.Color as Color
import Ui.TextStyle



-- PUBLIC


new :
    { label : String
    , onPress : Maybe msg
    }
    -> Button msg e a
new args =
    { label = args.label
    , onPress = args.onPress
    , style = defaultVisualStyle
    , statesFrom = Nothing
    , testId = Nothing
    }


withStyleDangerOnWhite : Button msg e a -> Button msg e a
withStyleDangerOnWhite props =
    { props | style = DangerOnWhite }


withStyleDangerOnBlack : Button msg e a -> Button msg e a
withStyleDangerOnBlack props =
    { props | style = DangerOnBlack }


withStyleWhiteOnBlack : Button msg e a -> Button msg e a
withStyleWhiteOnBlack props =
    { props | style = WhiteOnBlack }


withStatesFrom : RemoteData e a -> Button msg e a -> Button msg e a
withStatesFrom remoteData props =
    { props | statesFrom = Just remoteData }


withTestId : String -> Button msg e a -> Button msg e a
withTestId testId props =
    { props | testId = Just testId }


view : Button msg e a -> Element msg
view { label, onPress, style, statesFrom, testId } =
    let
        interactivityState : InteractivityState
        interactivityState =
            case statesFrom of
                Just remoteData ->
                    complexInteractivityState onPress remoteData

                Nothing ->
                    simpleInteractivityState onPress

        commonStyles : List (Attr () msg)
        commonStyles =
            [ height (px 52)
            , Border.rounded 50
            ]

        testIdAttributes : List (Attr () msg)
        testIdAttributes =
            Maybe.Extra.unwrap [] (Common.E2e.testId >> List.singleton) testId

        { backgroundStyleAttributes, styledLabel } =
            applyVisualStyle style interactivityState label
    in
    Input.button
        (commonStyles ++ backgroundStyleAttributes ++ testIdAttributes)
        { onPress = onPress
        , label = styledLabel
        }



-- IMPLEMENTATION DETAILS


{-| Note: The Focused option is useless as a state because elm-ui manages the focus state
Note: FocusedDisabled and BeingPressed are not visually worked out yet (not the same as Focused)
-}
type InteractivityState
    = Available
    | Disabled
    | DisabledBecauseLoading


type VisualStyle
    = WhiteOnBlack
    | DangerOnWhite
    | DangerOnBlack


defaultVisualStyle : VisualStyle
defaultVisualStyle =
    WhiteOnBlack


type alias Button msg e a =
    { label : String
    , onPress : Maybe msg

    -- Configurable props:
    , style : VisualStyle
    , statesFrom : Maybe (RemoteData e a)
    , testId : Maybe String
    }


{-| Style-specific version of each interactivity state. (Because not all styles require the inversion of gradient)
-}
applyVisualStyle :
    VisualStyle
    -> InteractivityState
    -> String
    -> { backgroundStyleAttributes : List (Attr () msg), styledLabel : Element msg }
applyVisualStyle visualStyle interactivityState labelText =
    case visualStyle of
        WhiteOnBlack ->
            applyVisualStyleWhiteOnBlack interactivityState labelText

        DangerOnWhite ->
            applyVisualStyleDangerOnWhite interactivityState labelText

        DangerOnBlack ->
            applyVisualStyleDangerOnBlack interactivityState labelText


defaultDisabledAttrs : List (Attr () msg)
defaultDisabledAttrs =
    [ alpha 0.5, focused [] ]


defaultLoadingAttrs : List (Attr () msg)
defaultLoadingAttrs =
    [ htmlAttribute <| Html.Attributes.class "animation-pulse", focused [] ]


defaultLabelAttrs : List (Attr () msg)
defaultLabelAttrs =
    [ centerX, centerY, paddingXY 24 0 ] ++ Ui.TextStyle.button


applyVisualStyleWhiteOnBlack :
    InteractivityState
    -> String
    -> { backgroundStyleAttributes : List (Attr () msg), styledLabel : Element msg }
applyVisualStyleWhiteOnBlack interactivityState labelText =
    let
        normalLabel : Element msg
        normalLabel =
            el (Font.color Color.white :: defaultLabelAttrs) <| text labelText
    in
    case interactivityState of
        Available ->
            { backgroundStyleAttributes =
                [ Background.color Color.black
                , focused [ Background.color Color.blackDimmed ]
                , mouseOver [ Background.color Color.blackDimmed ]
                ]
            , styledLabel = normalLabel
            }

        Disabled ->
            { backgroundStyleAttributes = Background.color Color.black :: defaultDisabledAttrs
            , styledLabel = normalLabel
            }

        DisabledBecauseLoading ->
            { backgroundStyleAttributes = Background.color Color.black :: defaultLoadingAttrs
            , styledLabel = normalLabel
            }


applyVisualStyleDangerOnWhite :
    InteractivityState
    -> String
    -> { backgroundStyleAttributes : List (Attr () msg), styledLabel : Element msg }
applyVisualStyleDangerOnWhite interactivityState labelText =
    let
        normalLabel : Element msg
        normalLabel =
            el (Font.color Color.dangerRed :: defaultLabelAttrs) <| text labelText
    in
    case interactivityState of
        Available ->
            { backgroundStyleAttributes =
                [ Background.color Color.white
                , focused [ Background.color Color.greyDimmed2 ]
                , mouseOver [ Background.color Color.greyDimmed2 ]
                ]
            , styledLabel = normalLabel
            }

        Disabled ->
            { backgroundStyleAttributes = Background.color Color.white :: defaultDisabledAttrs
            , styledLabel = normalLabel
            }

        DisabledBecauseLoading ->
            { backgroundStyleAttributes = Background.color Color.white :: defaultLoadingAttrs
            , styledLabel = normalLabel
            }


applyVisualStyleDangerOnBlack :
    InteractivityState
    -> String
    -> { backgroundStyleAttributes : List (Attr () msg), styledLabel : Element msg }
applyVisualStyleDangerOnBlack interactivityState labelText =
    let
        normalLabel : Element msg
        normalLabel =
            el (Font.color Color.dangerRed :: defaultLabelAttrs) <| text labelText
    in
    case interactivityState of
        Available ->
            { backgroundStyleAttributes =
                [ Background.color Color.black
                , focused [ Background.color Color.blackDimmed ]
                , mouseOver [ Background.color Color.blackDimmed ]
                ]
            , styledLabel = normalLabel
            }

        Disabled ->
            { backgroundStyleAttributes = Background.color Color.black :: defaultDisabledAttrs
            , styledLabel = normalLabel
            }

        DisabledBecauseLoading ->
            { backgroundStyleAttributes = Background.color Color.black :: defaultLoadingAttrs
            , styledLabel = normalLabel
            }


simpleInteractivityState : Maybe msg -> InteractivityState
simpleInteractivityState onPress =
    case onPress of
        Just _ ->
            Available

        Nothing ->
            Disabled


complexInteractivityState : Maybe msg -> RemoteData e a -> InteractivityState
complexInteractivityState onPress remoteData =
    case onPress of
        Just _ ->
            case remoteData of
                RemoteData.NotAsked ->
                    Available

                RemoteData.Loading ->
                    DisabledBecauseLoading

                RemoteData.Failure _ ->
                    Available

                RemoteData.Success _ ->
                    Available

        Nothing ->
            Disabled
