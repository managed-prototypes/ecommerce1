module Ui.Toast.Defaults exposing (config)

import Animation
import Element exposing (..)
import Ui.Toast.Library as Library


config : Library.Config msg toast
config =
    Library.config
        |> Library.transitionOutDuration 600
        |> Library.containerAttrs containerAttrs
        |> Library.transitionInFn transitionIn
        |> Library.transitionOutFn transitionOut
        |> Library.delay 5000


transitionIn : { toast | animationState : Animation.State } -> { toast | animationState : Animation.State }
transitionIn toast =
    { toast
        | animationState =
            Animation.interrupt
                [ Animation.to
                    [ Animation.opacity 1.0
                    ]
                ]
                toast.animationState
    }


transitionOut : { toast | animationState : Animation.State } -> { toast | animationState : Animation.State }
transitionOut toast =
    { toast
        | animationState =
            Animation.interrupt
                [ Animation.to
                    [ Animation.opacity 0.0
                    ]
                ]
                toast.animationState
    }


containerAttrs : List (Element.Attribute msg)
containerAttrs =
    [ Element.centerX
    , Element.pointer
    , Element.width (Element.px 350)
    , paddingXY 0 20
    , spacing 8
    ]
