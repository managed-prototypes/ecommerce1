module Pages.CustomerOrders exposing (Model, Msg, page)

import Api.Query as Query
import ApiTypes exposing (..)
import Common.Graphql
    exposing
        ( GraphqlData
        , GraphqlResult
        , publicQuery
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
    { orders : GraphqlData (List CustomerOrder)
    }


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared () =
    ( { orders = RemoteData.Loading }
    , getCustomerOrders shared
    )



-- Subscriptions
-- Library configs
-- Network requests


getCustomerOrders : Shared.Model -> Effect Msg
getCustomerOrders shared =
    publicQuery
        { query = Query.adminCustomerOrdersV1 ssCustomerOrder
        , onResponse = GotOrdersResponse
        }
        { graphqlUrl = shared.graphqlUrl }
        |> Effect.sendCmd



-- Msg, update


type Msg
    = GotOrdersResponse (GraphqlResult (List CustomerOrder))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GotOrdersResponse res ->
            ( { model | orders = RemoteData.fromResult res }, Effect.none )



-- View


view : Model -> View Msg
view model =
    { title = "Customer Orders"
    , attributes = []
    , element =
        column [ spacing 100 ]
            [ viewResponse viewOrders model.orders
            ]
    }


viewOrders : List CustomerOrder -> Element Msg
viewOrders orders =
    column [ spacing 80 ] <| List.map viewCustomerOrder orders


viewCustomerOrder : CustomerOrder -> Element Msg
viewCustomerOrder order =
    column [ spacing 20 ]
        [ text <| "Order " ++ order.orderId
        , viewCustomer order.customer
        , text <| "Stetus" ++ ApiTypes.showOrderStatus order.status
        , column [] <| List.map viewOrderItem order.items
        , text <| "Total: " ++ UsdAmount.show order.total
        , viewShippingOption order.shippingOption
        ]


viewCustomer : Customer -> Element Msg
viewCustomer customer =
    column []
        [ text <| customer.userId
        , text <| customer.displayName
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
