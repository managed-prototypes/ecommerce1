module Shared.Msg exposing (Msg(..))

import GridLayout1
import Ui.Toast exposing (Toast, ToastType)


type Msg
    = GotNewWindowSize GridLayout1.WindowSize
    | ToastMsg (Ui.Toast.Msg Toast)
    | AddToast ToastType
