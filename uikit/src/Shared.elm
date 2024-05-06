module Shared exposing
    ( Flags
    , Model
    , Msg
    , decoder
    , defaultPage
    , init
    , subscriptions
    , update
    )

import Browser.Events
import Dict
import Effect exposing (Effect)
import Element exposing (..)
import GridLayout1
import Json.Decode
import Route exposing (Route)
import Route.Path
import Shared.Model
import Shared.Msg
import Ui.Toast as Toast exposing (Toast)


defaultPage : { path : Route.Path.Path, query : Dict.Dict String String, hash : Maybe String }
defaultPage =
    { path = Route.Path.Colors, query = Dict.empty, hash = Nothing }



-- FLAGS


type alias Flags =
    { windowSize : GridLayout1.WindowSize }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "windowSize" GridLayout1.windowSizeDecoder)



-- INIT


type alias Model =
    Shared.Model.Model


layoutConfig : GridLayout1.LayoutConfig
layoutConfig =
    { mobileScreen =
        { minGridWidth = 1024
        , maxGridWidth = Just 1024
        , columnCount = 12
        , gutter = 16
        , margin = GridLayout1.SameAsGutter
        }
    }


{-| During the authentication flow, we'll run twice into the `init` function:

  - The first time, for the application very first run. And we proceed with the `Idle` state,
    waiting for the user (a.k.a you) to request a sign in.

  - The second time, after a sign in has been requested, the user is redirected to the
    authorization server and redirects the user back to our application, with a code
    and other fields as query parameters.

When query params are present (and valid), we consider the user `Authorized`.

-}
init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult _ =
    case flagsResult of
        Ok flags ->
            initReady flags

        Err _ ->
            ( { layout = GridLayout1.init layoutConfig { width = 1024, height = 768 }
              , toasties = Toast.initialState
              }
            , Effect.none
            )


initReady : Flags -> ( Model, Effect Msg )
initReady flags =
    ( { layout = GridLayout1.init layoutConfig flags.windowSize
      , toasties = Toast.initialState
      }
    , Effect.none
    )



-- Ports
-- Subscriptions


subscriptions : Route () -> Model -> Sub Msg
subscriptions _ model =
    Sub.batch
        [ Browser.Events.onResize (\width height -> Shared.Msg.GotNewWindowSize { width = width, height = height })
        , Toast.subscription Shared.Msg.ToastMsg model
        ]



-- Network requests
-- Msg, update


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Shared.Msg.GotNewWindowSize newWindowSize ->
            gotNewWindowSize model newWindowSize

        Shared.Msg.ToastMsg subMsg ->
            toastMsg model subMsg

        Shared.Msg.AddToast toast ->
            addToast model toast


gotNewWindowSize : Model -> GridLayout1.WindowSize -> ( Model, Effect Msg )
gotNewWindowSize model newWindowSize =
    ( { model | layout = GridLayout1.update model.layout newWindowSize }, Effect.none )


toastMsg : Model -> Toast.Msg Toast -> ( Model, Effect Msg )
toastMsg model subMsg =
    Toast.update Toast.config Shared.Msg.ToastMsg subMsg model
        |> Tuple.mapSecond Effect.sendCmd


addToast : Model -> Toast.ToastType -> ( Model, Effect Shared.Msg.Msg )
addToast model toast =
    let
        ( newModel, newCmd ) =
            ( model, Cmd.none )
                |> Toast.addToast Shared.Msg.ToastMsg toast
    in
    ( newModel, Effect.sendCmd newCmd )
