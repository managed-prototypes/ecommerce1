module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    , defaultPage
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Browser.Events
import Effect exposing (Effect)
import GridLayout1
import Json.Decode
import Route exposing (Route)
import Route.Path
import Shared.Config exposing (Config)
import Shared.Model
import Shared.Msg
import Ui.Toast as Toast exposing (Toast)


defaultPage : Route.Path.Path
defaultPage =
    Route.Path.CustomerOrders



-- FLAGS


type alias Flags =
    { config : Config, windowSize : GridLayout1.WindowSize }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map2 Flags
        (Json.Decode.field "config" Shared.Config.configDecoder)
        (Json.Decode.field "windowSize" <| GridLayout1.windowSizeDecoder)



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


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult _ =
    case flagsResult of
        Ok flags ->
            initOk flags

        Err _ ->
            initError


initOk : Flags -> ( Model, Effect Msg )
initOk flags =
    ( { layout = GridLayout1.init layoutConfig flags.windowSize
      , graphqlUrl = flags.config.graphqlUrl
      , toasties = Toast.initialState
      }
    , Effect.none
    )


{-| Note: The type forces us to return some Model, but we only are going to do the redirect to the error page.
-}
initError : ( Model, Effect Msg )
initError =
    let
        meaninglessDefaultModel : Shared.Model.Model
        meaninglessDefaultModel =
            { layout = GridLayout1.init layoutConfig { width = 1024, height = 768 }
            , graphqlUrl = ""
            , toasties = Toast.initialState
            }
    in
    ( meaninglessDefaultModel
    , Effect.loadExternalUrl "/error.html"
    )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions _ model =
    Sub.batch
        [ Browser.Events.onResize (\width height -> Shared.Msg.GotNewWindowSize { width = width, height = height })
        , Toast.subscription Shared.Msg.ToastMsg model
        ]



-- UPDATE


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
