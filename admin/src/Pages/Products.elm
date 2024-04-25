module Pages.Products exposing (Model, Msg, page)

import Api.Query as Query
import ApiTypes exposing (..)
import Common.Graphql
    exposing
        ( GraphqlData
        , GraphqlResult
        , publicQuery
        , viewResponse
        )
import Common.UsdPrice as UsdPrice
import Effect exposing (Effect)
import Element exposing (..)
import Layouts
import Page exposing (Page)
import RemoteData
import Route exposing (Route)
import Route.Path as Path
import Shared
import View exposing (View)



-- Ports
-- Page-specific types and related functions
-- Page-specific constants
-- Flags, main, page


page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init shared
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
        |> Page.withLayout (always <| Layouts.AdminLayout {})



-- Model, init


type alias Model =
    { products : GraphqlData (List Product)
    }


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared () =
    ( { products = RemoteData.Loading }
    , getProducts shared
    )



-- Subscriptions
-- Library configs
-- Network requests


getProducts : Shared.Model -> Effect Msg
getProducts shared =
    publicQuery
        { query = Query.adminProductsV1 ssProduct
        , onResponse = GotProductsResponse
        }
        { graphqlUrl = shared.graphqlUrl }
        |> Effect.sendCmd



-- Msg, update


type Msg
    = GotProductsResponse (GraphqlResult (List Product))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GotProductsResponse res ->
            ( { model | products = RemoteData.fromResult res }, Effect.none )



-- View


view : Model -> View Msg
view model =
    { title = "Shop"
    , attributes = []
    , element =
        column []
            [ link []
                { url = Path.toString Path.Products_New
                , label = text "New Product"
                }
            , viewResponse viewProducts model.products
            ]
    }


viewProducts : List Product -> Element Msg
viewProducts products =
    column [ spacing 50 ] (List.map viewProduct products)


viewProduct : Product -> Element Msg
viewProduct product =
    column [ width fill ]
        [ row [ spacing 50, width fill ]
            [ column []
                [ text product.title
                , text <| UsdPrice.show product.price
                ]
            , image [ width (px 100), height (px 100), alignRight ] { src = product.imageUrl, description = product.title }
            ]
        , row [ spacing 50 ]
            [ link []
                { url = Path.toString <| Path.Products_ProductId_ { productId = product.productId }
                , label = text "Edit"
                }
            , text <| "Delete"
            ]
        ]
