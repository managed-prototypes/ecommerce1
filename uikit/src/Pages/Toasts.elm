module Pages.Toasts exposing (Model, Msg, page)

import Effect exposing (Effect)
import Element exposing (..)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Ui.Button
import Ui.Color as Color
import Ui.Section
import Ui.TextStyle
import Ui.Toast exposing (ToastType(..))
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view shared
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


type Msg
    = AddToast ToastType


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        AddToast toast ->
            ( model, Effect.addToast toast )



-- SUBSCRIPTIONS
-- VIEW


view : Shared.Model -> Model -> View Msg
view { screenClass } _ =
    { title = "Toasts"
    , attributes = []
    , element =
        Ui.Section.withBackgroundColor { backgroundColor = Color.white, screenClass = screenClass } <|
            column [ spacing 50, width fill ]
                [ paragraph (paddingXY 0 50 :: Ui.TextStyle.subheader) [ text "Toasts" ]
                , Ui.Button.new
                    { label = "Short"
                    , onPress = Just <| AddToast <| Neutral "A thing created"
                    }
                    |> Ui.Button.withFullWidthOnMobile screenClass
                    |> Ui.Button.view
                , Ui.Button.new
                    { label = "Verbose"
                    , onPress = Just <| AddToast <| Neutral "Once upon a time, there was a thing created by the glorious user"
                    }
                    |> Ui.Button.withFullWidthOnMobile screenClass
                    |> Ui.Button.view
                , Ui.Button.new
                    { label = "Error"
                    , onPress = Just <| AddToast <| NeutralPersistent "Something went wrong. Lord help us with this one"
                    }
                    |> Ui.Button.withFullWidthOnMobile screenClass
                    |> Ui.Button.view
                ]
    }
