module Shared.Model exposing (Model)

import Ui.Toast
import Ui.Window exposing (WindowSize)


{-| Normally, this value would live in "Shared.elm"
but that would lead to a circular dependency import cycle.

For that reason, both `Shared.Model` and `Shared.Msg` are in their
own file, so they can be imported by `Effect.elm`

-}
type alias Model =
    { window : WindowSize
    , graphqlUrl : String
    , toasties : Ui.Toast.Stack Ui.Toast.Toast
    }
