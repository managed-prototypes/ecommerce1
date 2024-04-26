module Pages.Products.New exposing (Model, Msg, page)

import Api.Mutation as Mutation exposing (AdminProductCreateV1RequiredArguments)
import Common.Graphql
    exposing
        ( GraphqlData
        , GraphqlResult
        , showGraphqlError
        )
import Components.ProductEditor as ProductEditor
import Effect exposing (Effect)
import Element exposing (..)
import Layouts
import Page exposing (Page)
import RemoteData
import Route exposing (Route)
import Route.Path as Path
import Shared
import Ui.Button
import Ui.Toast
import View exposing (View)



-- Ports
-- Page-specific types and related functions
-- Page-specific constants
-- Flags, main, page


page : Shared.Model -> Route () -> Page Model Msg
page _ route =
    Page.new
        { init = init route
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
        |> Page.withLayout (always <| Layouts.AdminLayout {})



--- Model, init


type alias Model =
    { productCreateResponse : GraphqlData ()
    , imageUrlInput : String
    , titleInput : String
    , priceInput : String
    }


init : Route () -> () -> ( Model, Effect Msg )
init _ () =
    ( { productCreateResponse = RemoteData.NotAsked
      , imageUrlInput = ""
      , titleInput = ""
      , priceInput = ""
      }
    , Effect.none
    )



-- Subscriptions
-- Library configs
-- Network requests


createProduct : AdminProductCreateV1RequiredArguments -> Effect Msg
createProduct args =
    Effect.protectedMutation
        { mutation = Mutation.adminProductCreateV1 args
        , onResponse = GotProductCreateResponse
        }



-- Msg, update


type Msg
    = GotProductCreateResponse (GraphqlResult ())
    | ImageUrlInputChanged String
    | TitleInputChanged String
    | PriceInputChanged String
    | SaveClicked AdminProductCreateV1RequiredArguments


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GotProductCreateResponse res ->
            case res of
                Ok () ->
                    ( { model
                        | productCreateResponse = RemoteData.Success ()
                      }
                    , Effect.batch
                        [ Effect.pushRoutePath Path.Products
                        , Effect.addToast (Ui.Toast.Neutral "Product created successfully.")
                        ]
                    )

                Err e ->
                    ( { model | productCreateResponse = RemoteData.Failure e }
                    , Effect.addToast <| Ui.Toast.NeutralPersistent <| showGraphqlError e
                    )

        ImageUrlInputChanged str ->
            ( { model | imageUrlInput = str }, Effect.none )

        TitleInputChanged str ->
            ( { model | titleInput = str }, Effect.none )

        PriceInputChanged str ->
            ( { model | priceInput = str }, Effect.none )

        SaveClicked args ->
            ( model, createProduct args )



-- View
-- VIEW


view : Model -> View Msg
view model =
    { title = "New Product"
    , attributes = []
    , element =
        column []
            [ viewProductEditor model
            ]
    }


viewProductEditor : Model -> Element Msg
viewProductEditor model =
    column [ spacing 20 ]
        [ ProductEditor.view model
            { onImageUrlInputChanged = ImageUrlInputChanged
            , onTitleInputChanged = TitleInputChanged
            , onPriceInputChanged = PriceInputChanged
            }
        , row [ spacing 50 ]
            [ Ui.Button.new
                { label = "Save"
                , onPress =
                    ProductEditor.toProductInput model
                        |> Maybe.map
                            (\productInput ->
                                SaveClicked { productInput = productInput }
                            )
                }
                |> Ui.Button.withStatesFrom model.productCreateResponse
                |> Ui.Button.view
            , text "Cancel"
            ]
        ]
