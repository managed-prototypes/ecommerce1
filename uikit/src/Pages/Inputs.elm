module Pages.Inputs exposing (Model, Msg, page)

import Effect exposing (Effect)
import Element exposing (..)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Ui.Color as Color
import Ui.Input
import Ui.Section
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page _ _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
        |> Page.withLayout toLayout


toLayout : Model -> Layouts.Layout Msg
toLayout _ =
    Layouts.UiKitLayout {}



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}, Effect.none )



-- UPDATE


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Effect Msg )
update _ model =
    ( model, Effect.none )



-- SUBSCRIPTIONS
-- VIEW


view : Model -> View Msg
view _ =
    { title = "Colors"
    , attributes = []
    , element =
        Ui.Section.withBackgroundColor { backgroundColor = Color.white } <|
            column [ spacing 50, width fill ]
                [ Ui.Input.new
                    { label = "Address"
                    , placeholder = "Some address"
                    , text = ""
                    , onChange = always ()
                    }
                    |> Ui.Input.view
                , Ui.Input.new
                    { label = "Address"
                    , placeholder = "Some address"
                    , text = "Filled"
                    , onChange = always ()
                    }
                    |> Ui.Input.view
                ]
    }
