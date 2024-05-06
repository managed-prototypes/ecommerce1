port module Layouts.WebappLayout exposing (Model, Msg, Props, layout)

import Effect exposing (Effect)
import Element exposing (..)
import GridLayout1
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path as Path
import Shared
import Ui.TextStyle
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
    , attributes = GridLayout1.bodyAttributes shared.layout ++ Ui.TextStyle.body ++ content.attributes
    , element =
        let
            viewMenu : Element msg
            viewMenu =
                row [ spacing 50 ]
                    [ link []
                        { url = Path.toString Path.Shop
                        , label = text "Shop"
                        }
                    , link []
                        { url = Path.toString Path.Cart
                        , label = text "Cart"
                        }
                    , link []
                        { url = Path.toString Path.MyOrders
                        , label = text "My Orders"
                        }
                    , image []
                        { src = VitePluginHelper.asset "/assets/icons/sign-out.svg"
                        , description = "Placeholder"
                        }
                    ]

            outerElementAttrs : List (Attribute msg)
            outerElementAttrs =
                []

            innerElementAttrs : List (Attribute contentMsg)
            innerElementAttrs =
                [ Element.inFront (Element.map toContentMsg <| Toast.view PassToastMsg shared.toasties) ]

            outerElement : List (Element msg) -> Element msg
            outerElement =
                column (GridLayout1.layoutOuterAttributes ++ outerElementAttrs)

            innerElement : List (Element contentMsg) -> Element contentMsg
            innerElement =
                column (GridLayout1.layoutInnerAttributes shared.layout ++ innerElementAttrs)
        in
        outerElement [ innerElement [ viewMenu, content.element ] ]
    }
