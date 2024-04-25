module Pages.Typography exposing (Model, Msg, page)

import Effect exposing (Effect)
import Element exposing (..)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Ui.Color as Color
import Ui.Section
import Ui.TextStyle
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
    { title = "Typography"
    , attributes = []
    , element =
        Ui.Section.withBackgroundColor { backgroundColor = Color.white } <|
            column [ spacing 50, width fill ]
                [ paragraph Ui.TextStyle.headlineXL [ text "Headline XL" ]
                , paragraph Ui.TextStyle.headlineL [ text "Headline L" ]
                , paragraph Ui.TextStyle.headlineS [ text "Headline S" ]
                , paragraph Ui.TextStyle.header [ text "Header" ]
                , paragraph Ui.TextStyle.subheader [ text "Subheader" ]
                , paragraph Ui.TextStyle.button [ text "Button" ]
                , paragraph Ui.TextStyle.body [ text "Body" ]
                ]
    }
