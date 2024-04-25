module Pages.Products.ProductId_ exposing (Model, Msg, page)

import Api.Mutation as Mutation exposing (AdminProductUpdateV1RequiredArguments)
import Api.Query as Query
import ApiTypes exposing (..)
import Common.Graphql
    exposing
        ( GraphqlData
        , GraphqlResult
        , publicMutation
        , publicQuery
        , showGraphqlError
        , viewResponse
        )
import Common.UsdPrice as UsdPrice
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


page : Shared.Model -> Route { productId : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init shared route
        , update = update shared
        , subscriptions = always Sub.none
        , view = view
        }
        |> Page.withLayout (always <| Layouts.AdminLayout {})



--- Model, init


type alias Model =
    { product : GraphqlData Product
    , productUpdateResponse : GraphqlData ()
    , imageUrlInput : String
    , titleInput : String
    , priceInput : String
    }


init : Shared.Model -> Route { productId : String } -> () -> ( Model, Effect Msg )
init shared route () =
    ( { product = RemoteData.Loading
      , productUpdateResponse = RemoteData.NotAsked
      , imageUrlInput = ""
      , titleInput = ""
      , priceInput = ""
      }
    , getProduct shared { productId = route.params.productId }
    )



-- Subscriptions
-- Library configs
-- Network requests


getProduct : Shared.Model -> { productId : String } -> Effect Msg
getProduct shared args =
    publicQuery
        { query = Query.adminProductV1 args ssProduct
        , onResponse = GotProductResponse
        }
        { graphqlUrl = shared.graphqlUrl }
        |> Effect.sendCmd


updateProduct : Shared.Model -> AdminProductUpdateV1RequiredArguments -> Effect Msg
updateProduct shared args =
    publicMutation
        { mutation = Mutation.adminProductUpdateV1 args
        , onResponse = GotProductUpdateResponse
        }
        { graphqlUrl = shared.graphqlUrl }
        |> Effect.sendCmd



-- Msg, update


type Msg
    = GotProductResponse (GraphqlResult Product)
    | GotProductUpdateResponse (GraphqlResult ())
    | ImageUrlInputChanged String
    | TitleInputChanged String
    | PriceInputChanged String
    | SaveClicked AdminProductUpdateV1RequiredArguments


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
        GotProductResponse res ->
            let
                newModel : Model
                newModel =
                    case res of
                        Ok product ->
                            { model
                                | product = RemoteData.Success product
                                , imageUrlInput = product.imageUrl
                                , titleInput = product.title
                                , priceInput = UsdPrice.toUserInput product.price
                            }

                        Err err ->
                            { model | product = RemoteData.Failure err }
            in
            ( newModel
            , Effect.none
            )

        GotProductUpdateResponse res ->
            case res of
                Ok () ->
                    ( { model
                        | productUpdateResponse = RemoteData.Success ()
                      }
                    , Effect.batch
                        [ Effect.pushRoutePath Path.Products
                        , Effect.addToast (Ui.Toast.Neutral "Product updated successfully.")
                        ]
                    )

                Err e ->
                    ( { model | productUpdateResponse = RemoteData.Failure e }
                    , Effect.addToast <| Ui.Toast.NeutralPersistent <| showGraphqlError e
                    )

        ImageUrlInputChanged str ->
            ( { model | imageUrlInput = str }, Effect.none )

        TitleInputChanged str ->
            ( { model | titleInput = str }, Effect.none )

        PriceInputChanged str ->
            ( { model | priceInput = str }, Effect.none )

        SaveClicked args ->
            ( model, updateProduct shared args )



-- View
-- VIEW


view : Model -> View Msg
view model =
    { title = "Edit Product"
    , attributes = []
    , element = column [] [ viewResponse (viewProductEditor model) model.product ]
    }


viewProductEditor : Model -> Product -> Element Msg
viewProductEditor model existingProduct =
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
                                SaveClicked { productId = existingProduct.productId, productInput = productInput }
                            )
                }
                |> Ui.Button.withStatesFrom model.productUpdateResponse
                |> Ui.Button.view
            , text "Cancel"
            , text "Delete"
            ]
        ]
