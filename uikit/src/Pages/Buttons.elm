module Pages.Buttons exposing (Model, Msg, page)

import Effect exposing (Effect)
import Element exposing (..)
import Layouts
import Page exposing (Page)
import RemoteData
import Route exposing (Route)
import Shared
import Ui.Button
import Ui.TextStyle
import UiKitUtils exposing (viewOnBothBackgrounds)
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
    { title = "Buttons"
    , attributes = []
    , element =
        column [ width fill ]
            [ paragraph (paddingXY 0 50 :: Ui.TextStyle.subheader) [ text "Default" ]
            , wrappedRow
                [ width fill ]
                [ viewOnBothBackgrounds { title = "WhiteOnBlack" }
                    [ Ui.Button.new
                        { label = "Normal"
                        , onPress = Just ()
                        }
                        |> Ui.Button.withStyleWhiteOnBlack
                        |> Ui.Button.view
                    , Ui.Button.new
                        { label = "Disabled"
                        , onPress = Nothing
                        }
                        |> Ui.Button.withStyleWhiteOnBlack
                        |> Ui.Button.view
                    , Ui.Button.new
                        { label = "Loading"
                        , onPress = Just ()
                        }
                        |> Ui.Button.withStyleWhiteOnBlack
                        |> Ui.Button.withStatesFrom RemoteData.Loading
                        |> Ui.Button.view
                    ]
                ]
            , paragraph (paddingXY 0 50 :: Ui.TextStyle.subheader) [ text "Danger" ]
            , wrappedRow
                [ width fill ]
                [ viewOnBothBackgrounds { title = "DangerOnWhite" }
                    [ Ui.Button.new
                        { label = "Normal"
                        , onPress = Just ()
                        }
                        |> Ui.Button.withStyleDangerOnWhite
                        |> Ui.Button.view
                    , Ui.Button.new
                        { label = "Disabled"
                        , onPress = Nothing
                        }
                        |> Ui.Button.withStyleDangerOnWhite
                        |> Ui.Button.view
                    , Ui.Button.new
                        { label = "Loading"
                        , onPress = Just ()
                        }
                        |> Ui.Button.withStyleDangerOnWhite
                        |> Ui.Button.withStatesFrom RemoteData.Loading
                        |> Ui.Button.view
                    ]
                , viewOnBothBackgrounds { title = "DangerOnBlack" }
                    [ Ui.Button.new
                        { label = "Normal"
                        , onPress = Just ()
                        }
                        |> Ui.Button.withStyleDangerOnBlack
                        |> Ui.Button.view
                    , Ui.Button.new
                        { label = "Disabled"
                        , onPress = Nothing
                        }
                        |> Ui.Button.withStyleDangerOnBlack
                        |> Ui.Button.view
                    , Ui.Button.new
                        { label = "Loading"
                        , onPress = Just ()
                        }
                        |> Ui.Button.withStyleDangerOnBlack
                        |> Ui.Button.withStatesFrom RemoteData.Loading
                        |> Ui.Button.view
                    ]
                ]
            ]
    }
