module Pages.Home_ exposing (Model, Msg, page)

import Effect
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View


{-| Since we do not have a dedicated Home page,
we will just immediately transfer the user to the default page
-}
page : Shared.Model -> Route () -> Page Model Msg
page _ _ =
    Page.new
        { init = \_ -> ( (), Effect.replaceRoute Shared.defaultPage )
        , update = \_ model -> ( model, Effect.none )
        , subscriptions = always Sub.none
        , view = \_ -> View.none
        }


type alias Model =
    ()


type alias Msg =
    ()
