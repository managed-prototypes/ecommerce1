port module Layouts.UiKitLayout exposing (Model, Msg, Props, layout)

import Effect exposing (Effect)
import Element exposing (..)
import Element.Font as Font
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path as Path
import Shared
import Ui.Color as Color
import Ui.Constants
import Ui.Section
import Ui.TextStyle
import Ui.Toast as Toast exposing (Toast)
import View exposing (View)


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
        let
            links : List { url : String, caption : String }
            links =
                [ { url = Path.toString Path.Typography, caption = "Typography" }
                , { url = Path.toString Path.Colors, caption = "Colors" }
                , { url = Path.toString Path.Buttons, caption = "Buttons" }
                , { url = Path.toString Path.Toasts, caption = "Toasts" }
                ]

            viewMenu : Element msg
            viewMenu =
                links
                    |> List.map (\x -> link [ Font.color Color.primaryBlue ] { url = x.url, label = text x.caption })
                    |> wrappedRow [ spacing 20, paddingXY 0 50 ]
                    |> Ui.Section.withBackgroundColor { backgroundColor = Color.white }
        in
        column
            ([ width (fill |> minimum Ui.Constants.minimalSupportedMobileScreenWidth)
             , Element.inFront (Element.map toContentMsg <| Toast.view PassToastMsg shared.toasties)
             ]
                ++ Ui.TextStyle.body
            )
            [ viewMenu
            , content.element
            ]
    }
