module Pages.Home_ exposing (Model, Msg, page)

import Effect
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View


{-|

  - An unauthorized user from the root will be transferred to defaultPage, but Auth.onPageLoad will refuse to render it.
      - Authorization will be forced by Shared.init
  - An authorized user who has just arrived from Zitadel, and who does not yet have tokens,
    will also be transferred to defaultPage and it will wait for Auth.onPageLoad to resolve init/render.
      - Redirect will execute Shared.update when tokens arrive
  - An authorized user who immediately has tokens will immediately be transferred to defaultPage

-}
page : Shared.Model -> Route () -> Page Model Msg
page _ _ =
    Page.new
        { init = \_ -> ( (), Effect.replaceRoutePath Shared.defaultPage )
        , update = \_ model -> ( model, Effect.none )
        , subscriptions = always Sub.none
        , view = \_ -> View.none
        }


type alias Model =
    ()


type alias Msg =
    ()
