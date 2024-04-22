module Pages.NotFound_ exposing (Model, Msg, page)

import Effect
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View


{-| Since the NotFound page is only needed in Elm Land to handle routing errors,
and not to display a response that a particular object was not found in the API,
we will simply immediately transfer the user to the default page.
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
