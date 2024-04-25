module Ui.Toast exposing
    ( Msg
    , Stack
    , Toast
    , ToastType(..)
    , addToast
    , config
    , initialState
    , subscription
    , update
    , view
    )

import Animation
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Ui.Color as Color
import Ui.Constants
import Ui.Toast.Defaults
import Ui.Toast.Library as Library



-- import Util.BackendData as BackendData exposing (BackendHttpError)
-- Library re-exports


type alias Stack toast =
    Library.Stack toast


type alias Msg toast =
    Library.Msg toast


initialState : Stack toast
initialState =
    Library.initialState


subscription : (Library.Msg Toast -> msg) -> { model | toasties : Library.Stack Toast } -> Sub msg
subscription =
    Library.subscription


update :
    Library.Config msg Toast
    -> (Msg Toast -> msg)
    -> Msg Toast
    -> { model | toasties : Stack Toast }
    -> ( { model | toasties : Stack Toast }, Cmd msg )
update =
    Library.update



-- This is Wolf's client code for the library


type alias Toast =
    { animationState : Animation.State
    , toastType : ToastType
    }


type ToastType
    = Neutral String
    | NeutralPersistent String


config : Library.Config msg Toast
config =
    Ui.Toast.Defaults.config


addToast :
    (Library.Msg Toast -> msg)
    -> ToastType
    -> ( { model | toasties : Library.Stack Toast }, Cmd msg )
    -> ( { model | toasties : Library.Stack Toast }, Cmd msg )
addToast toMsg toastType =
    case toastType of
        Neutral _ ->
            Library.addToast config
                toMsg
                { toastType = toastType
                , animationState =
                    Animation.style
                        [ Animation.opacity 0.0 ]
                }

        NeutralPersistent _ ->
            Library.addPersistentToast config
                toMsg
                { toastType = toastType
                , animationState =
                    Animation.style
                        [ Animation.opacity 0.0 ]
                }


view : (Msg Toast -> msg) -> Stack Toast -> Element msg
view toMsg toasties =
    Library.view config viewToast toMsg toasties


viewToast : Toast -> Element msg
viewToast toast =
    let
        commonStyle : List (Attribute msg)
        commonStyle =
            [ width fill, Ui.Constants.roundBorder, Background.color Color.black ] ++ List.map Element.htmlAttribute (Animation.render toast.animationState)
    in
    case toast.toastType of
        Neutral str ->
            column
                (commonStyle ++ [ paddingXY 32 20 ])
                [ paragraph [ Font.color Color.white, Font.center ] [ text str ] ]

        NeutralPersistent str ->
            column
                (commonStyle ++ [ spacing 24, paddingEach { top = 20, right = 32, bottom = 24, left = 32 } ])
                [ paragraph [ Font.color Color.white, Font.center ] [ text str ]
                , el [ centerX, Font.color Color.white ] <| text "OK"
                ]
