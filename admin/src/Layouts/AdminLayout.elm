port module Layouts.AdminLayout exposing (Model, Msg, Props, layout)

import Effect exposing (Effect)
import Element exposing (..)
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path as Path
import Shared
import Ui.Toast as Toast exposing (Toast)
import View exposing (View)
import VitePluginHelper


port urlChanged : () -> Cmd msg


type alias Props =
    {}


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout _ shared _ =
    Layout.new
        { init = init
        , update = update
        , view = view shared
        , subscriptions = always Sub.none
        }
        |> Layout.withOnUrlChanged (always UrlChanged)



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = UrlChanged
    | PassToastMsg (Toast.Msg Toast)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UrlChanged ->
            ( model, Effect.sendCmd <| urlChanged () )

        PassToastMsg toastMsg ->
            ( model, Effect.passToastMsg toastMsg )



-- VIEW


view : Shared.Model -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view shared { toContentMsg, content } =
    { title = content.title
    , attributes = content.attributes
    , element =
        column
            [ padding 50
            , spacing 50
            , Element.inFront (Element.map toContentMsg <| Toast.view PassToastMsg shared.toasties)
            ]
            [ row [ spacing 50 ]
                [ link []
                    { url = Path.toString Path.CustomerOrders
                    , label = text "Orders"
                    }
                , link []
                    { url = Path.toString Path.Products
                    , label = text "Products"
                    }
                , image []
                    { src = VitePluginHelper.asset "/assets/icons/sign-out.svg"
                    , description = "Placeholder"
                    }
                ]
            , content.element
            ]
    }
