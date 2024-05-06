module Pages.Colors exposing (Model, Msg, page)

import Effect exposing (Effect)
import Element exposing (..)
import Element.Background as Background
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Ui.Color as Color
import Ui.TextStyle
import UiKitUtils exposing (smallGreyCaption)
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
        column [ spacing 50, width fill ]
            [ paragraph (paddingXY 0 50 :: Ui.TextStyle.subheader) [ text "Colors to be used directly" ]
            , [ ( Color.black, "black" )
              , ( Color.blackDimmed, "blackDimmed" )
              , ( Color.grey, "grey" )
              , ( Color.greyDimmed1, "greyDimmed1" )
              , ( Color.greyDimmed2, "greyDimmed2" )
              , ( Color.greyDimmed3, "greyDimmed3" )
              , ( Color.white, "white" )
              , ( Color.dangerRed, "dangerRed" )
              , ( Color.primaryBlue, "primaryBlue" )
              ]
                |> List.map viewColorSample
                |> wrappedRow [ spacing 30, width fill ]
            ]
    }


viewColorSample : ( Color, String ) -> Element msg
viewColorSample ( color, title ) =
    column [ spacing 16 ]
        [ column
            [ width (px 100)
            , height (px 100)
            , centerX
            , Background.color color
            ]
            []
        , el (centerX :: smallGreyCaption) <| text title
        ]
