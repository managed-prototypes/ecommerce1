module Shared.Model exposing (Model)

import GridLayout1
import Ui.Toast


type alias Model =
    { layout : GridLayout1.LayoutState
    , toasties : Ui.Toast.Stack Ui.Toast.Toast
    }
