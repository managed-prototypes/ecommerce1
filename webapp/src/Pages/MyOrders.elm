module Pages.MyOrders exposing (Model, Msg, page)

import Api.Query as Query
import ApiTypes exposing (..)
import Common.Graphql
    exposing
        ( GraphqlData
        , GraphqlResult
        , viewResponse
        )
import Common.UsdAmount as UsdAmount
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
    { orders : GraphqlData (List ApiTypes.Order)
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { orders = RemoteData.Loading }
    , getMyOrders
    )



-- Subscriptions
-- Library configs
-- Network requests


getMyOrders : Effect Msg
getMyOrders =
    Effect.protectedQuery
        { query = Query.myOrdersV1 ssOrder
        , onResponse = GotOrdersResponse
        }



-- Msg, update


type Msg
    = GotOrdersResponse (GraphqlResult (List ApiTypes.Order))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GotOrdersResponse res ->
            ( { model | orders = RemoteData.fromResult res }, Effect.none )



-- View


view : Model -> View Msg
view model =
    { title = "My Orders"
    , attributes = []
    , element =
        column [ spacing 100 ]
            [ viewResponse viewOrders model.orders
            ]
    }


viewOrders : List ApiTypes.Order -> Element Msg
viewOrders orders =
    column [ spacing 80 ] <| List.map viewOrder orders


viewOrder : ApiTypes.Order -> Element Msg
viewOrder order =
    column [ spacing 20 ]
        [ text <| "Order " ++ order.orderId
        , text <| "Stetus" ++ ApiTypes.showOrderStatus order.status
        , column [] <| List.map viewOrderItem order.items
        , text <| "Total: " ++ UsdAmount.show order.total
        , viewShippingOption order.shippingOption
        ]


viewShippingOption : ShippingOption -> Element Msg
viewShippingOption shippingOption =
    case shippingOption of
        Pickup pickupPoint ->
            text <| "Pickup at " ++ pickupPoint.title

        Delivery delivery ->
            text <| "Delivery to " ++ delivery.address


viewOrderItem : OrderItem -> Element Msg
viewOrderItem item =
    row [ spacing 50 ]
        [ text <| item.product.title
        , text <| UsdPrice.show item.product.price
        , text <| String.fromInt item.quantity
        , text <| UsdAmount.show item.itemTotal
        ]
