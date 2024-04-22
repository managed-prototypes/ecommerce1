module Pages.Buttons exposing (Model, Msg, page)

import Effect exposing (Effect)
import Element exposing (..)
import Layouts
import Page exposing (Page)
import RemoteData
import Route exposing (Route)
import Shared
import Ui.Button
import Ui.Color as Color
import Ui.Section
import Ui.TextStyle
import UiKitUtils exposing (deviceAwareContainer, viewOnBothBackgrounds)
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


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Effect Msg )
update _ model =
    ( model, Effect.none )



-- SUBSCRIPTIONS
-- VIEW


view : Shared.Model -> Model -> View Msg
view { screenClass } _ =
    { title = "Buttons"
    , attributes = []
    , element =
        Ui.Section.withBackgroundColor { backgroundColor = Color.white, screenClass = screenClass } <|
            column [ width fill ]
                [ paragraph (paddingXY 0 50 :: Ui.TextStyle.subheader) [ text "Default" ]
                , deviceAwareContainer screenClass
                    [ width fill ]
                    [ viewOnBothBackgrounds { title = "WhiteOnBlack", screenClass = screenClass }
                        [ Ui.Button.new
                            { label = "Normal"
                            , onPress = Just ()
                            }
                            |> Ui.Button.withStyleWhiteOnBlack
                            |> Ui.Button.withFullWidthOnMobile screenClass
                            |> Ui.Button.view
                        , Ui.Button.new
                            { label = "Disabled"
                            , onPress = Nothing
                            }
                            |> Ui.Button.withStyleWhiteOnBlack
                            |> Ui.Button.withFullWidthOnMobile screenClass
                            |> Ui.Button.view
                        , Ui.Button.new
                            { label = "Loading"
                            , onPress = Just ()
                            }
                            |> Ui.Button.withStyleWhiteOnBlack
                            |> Ui.Button.withStatesFrom RemoteData.Loading
                            |> Ui.Button.withFullWidthOnMobile screenClass
                            |> Ui.Button.view
                        ]
                    ]
                , paragraph (paddingXY 0 50 :: Ui.TextStyle.subheader) [ text "Danger" ]
                , deviceAwareContainer screenClass
                    [ width fill ]
                    [ viewOnBothBackgrounds { title = "DangerOnWhite", screenClass = screenClass }
                        [ Ui.Button.new
                            { label = "Normal"
                            , onPress = Just ()
                            }
                            |> Ui.Button.withStyleDangerOnWhite
                            |> Ui.Button.withFullWidthOnMobile screenClass
                            |> Ui.Button.view
                        , Ui.Button.new
                            { label = "Disabled"
                            , onPress = Nothing
                            }
                            |> Ui.Button.withStyleDangerOnWhite
                            |> Ui.Button.withFullWidthOnMobile screenClass
                            |> Ui.Button.view
                        , Ui.Button.new
                            { label = "Loading"
                            , onPress = Just ()
                            }
                            |> Ui.Button.withStyleDangerOnWhite
                            |> Ui.Button.withStatesFrom RemoteData.Loading
                            |> Ui.Button.withFullWidthOnMobile screenClass
                            |> Ui.Button.view
                        ]
                    , viewOnBothBackgrounds { title = "DangerOnBlack", screenClass = screenClass }
                        [ Ui.Button.new
                            { label = "Normal"
                            , onPress = Just ()
                            }
                            |> Ui.Button.withStyleDangerOnBlack
                            |> Ui.Button.withFullWidthOnMobile screenClass
                            |> Ui.Button.view
                        , Ui.Button.new
                            { label = "Disabled"
                            , onPress = Nothing
                            }
                            |> Ui.Button.withStyleDangerOnBlack
                            |> Ui.Button.withFullWidthOnMobile screenClass
                            |> Ui.Button.view
                        , Ui.Button.new
                            { label = "Loading"
                            , onPress = Just ()
                            }
                            |> Ui.Button.withStyleDangerOnBlack
                            |> Ui.Button.withStatesFrom RemoteData.Loading
                            |> Ui.Button.withFullWidthOnMobile screenClass
                            |> Ui.Button.view
                        ]
                    ]
                ]
    }
