module ApiTypes exposing (..)

import Api.Enum.OrderStatus exposing (OrderStatus(..))
import Api.Object
import Api.Object.Cart as Cart
import Api.Object.CartItem as CartItem
import Api.Object.Customer as Customer
import Api.Object.CustomerOrder as CustomerOrder
import Api.Object.Order as Order
import Api.Object.OrderItem as OrderItem
import Api.Object.PickupPoint as PickupPoint
import Api.Object.Product as Product
import Api.Object.ShippingOptionDelivery as ShippingOptionDelivery
import Api.Union
import Api.Union.ShippingOption as ShippingOption
import Common.UsdAmount exposing (UsdAmount)
import Common.UsdPrice exposing (UsdPrice)
import Graphql.SelectionSet as SelectionSet


type alias Product =
    { productId : String
    , title : String
    , imageUrl : String
    , price : UsdPrice
    }


ssProduct : SelectionSet.SelectionSet Product Api.Object.Product
ssProduct =
    SelectionSet.map4 Product
        Product.productId
        Product.title
        Product.imageUrl
        Product.price


type alias CartItem =
    { product : Product
    , quantity : Int
    , itemTotal : UsdAmount
    }


ssCartItem : SelectionSet.SelectionSet CartItem Api.Object.CartItem
ssCartItem =
    SelectionSet.map3 CartItem
        (CartItem.product ssProduct)
        CartItem.quantity
        CartItem.itemTotal


type alias Cart =
    { items : List CartItem
    , total : UsdAmount
    }


ssCart : SelectionSet.SelectionSet Cart Api.Object.Cart
ssCart =
    SelectionSet.map2 Cart
        (Cart.items ssCartItem)
        Cart.total


type alias PickupPoint =
    { pickupPointId : String
    , title : String
    }


ssPickupPoint : SelectionSet.SelectionSet PickupPoint Api.Object.PickupPoint
ssPickupPoint =
    SelectionSet.map2 PickupPoint
        PickupPoint.pickupPointId
        PickupPoint.title


type alias OrderItem =
    { product : Product
    , quantity : Int
    , itemTotal : UsdAmount
    }


ssOrderItem : SelectionSet.SelectionSet OrderItem Api.Object.OrderItem
ssOrderItem =
    SelectionSet.map3 OrderItem
        (OrderItem.product ssProduct)
        OrderItem.quantity
        OrderItem.itemTotal


type alias ShippingOptionDelivery =
    { address : String
    }


ssShippingOptionDelivery : SelectionSet.SelectionSet ShippingOptionDelivery Api.Object.ShippingOptionDelivery
ssShippingOptionDelivery =
    SelectionSet.map ShippingOptionDelivery
        ShippingOptionDelivery.address


type ShippingOption
    = Pickup PickupPoint
    | Delivery ShippingOptionDelivery


ssShippingOption : SelectionSet.SelectionSet ShippingOption Api.Union.ShippingOption
ssShippingOption =
    ShippingOption.fragments
        { onPickupPoint = SelectionSet.map Pickup ssPickupPoint
        , onShippingOptionDelivery = SelectionSet.map Delivery ssShippingOptionDelivery
        }


showOrderStatus : OrderStatus -> String
showOrderStatus status =
    case status of
        Pending ->
            "Pending"

        Shipped ->
            "Shipped"

        Delivered ->
            "Delivered"

        Cancelled ->
            "Cancelled"


type alias Order =
    { orderId : String
    , items : List OrderItem
    , status : OrderStatus
    , total : UsdAmount
    , shippingOption : ShippingOption
    }


ssOrder : SelectionSet.SelectionSet Order Api.Object.Order
ssOrder =
    SelectionSet.map5 Order
        Order.orderId
        (Order.items ssOrderItem)
        Order.status
        Order.total
        (Order.shippingOption ssShippingOption)


type alias Customer =
    { userId : String
    , displayName : String
    }


ssCustomer : SelectionSet.SelectionSet Customer Api.Object.Customer
ssCustomer =
    SelectionSet.map2 Customer
        Customer.userId
        Customer.displayName


type alias CustomerOrder =
    { orderId : String
    , customer : Customer
    , items : List OrderItem
    , status : OrderStatus
    , total : UsdAmount
    , shippingOption : ShippingOption
    }


ssCustomerOrder : SelectionSet.SelectionSet CustomerOrder Api.Object.CustomerOrder
ssCustomerOrder =
    SelectionSet.map6 CustomerOrder
        CustomerOrder.orderId
        (CustomerOrder.customer ssCustomer)
        (CustomerOrder.items ssOrderItem)
        CustomerOrder.status
        CustomerOrder.total
        (CustomerOrder.shippingOption ssShippingOption)
