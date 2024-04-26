module Pages.Shop exposing (Model, Msg, page)

import Api.Query as Query
import ApiTypes exposing (..)
import Common.Graphql
    exposing
        ( GraphqlData
        , GraphqlResult
        , viewResponse
        )
import Common.UsdPrice as UsdPrice
import Effect exposing (Effect)
import Element exposing (..)
import Layouts
import Page exposing (Page)
import RemoteData
import Route exposing (Route)
import Shared
import View exposing (View)



-- Ports
-- Page-specific types and related functions
-- Page-specific constants
-- Flags, main, page


page : Shared.Model -> Route () -> Page Model Msg
page _ _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
        |> Page.withLayout (always <| Layouts.WebappLayout {})



-- Model, init


type alias Model =
    { products : GraphqlData (List Product)
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { products = RemoteData.Loading }
    , getProducts
    )



-- Subscriptions
-- Library configs
-- Network requests


getProducts : Effect Msg
getProducts =
    Effect.publicQuery
        { query = Query.productsV1 ssProduct
        , onResponse = GotProductsResponse
        }



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
    , element = column [] [ viewResponse viewProducts model.products ]
    }


viewProducts : List Product -> Element Msg
viewProducts products =
    column [ spacing 50 ] (List.map viewProduct products)


viewProduct : Product -> Element Msg
viewProduct product =
    column []
        [ image [ width (px 400), height (px 400) ] { src = product.imageUrl, description = product.title }
        , text product.title
        , text <| "Add " ++ UsdPrice.show product.price
        ]
