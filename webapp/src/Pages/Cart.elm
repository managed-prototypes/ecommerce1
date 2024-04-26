module Pages.Cart exposing (Model, Msg, page)

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
    { cart : GraphqlData Cart
    , pickupPoints : GraphqlData (List PickupPoint)
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { cart = RemoteData.Loading
      , pickupPoints = RemoteData.Loading
      }
    , Effect.batch [ getCart, getPickupPoints ]
    )



-- Subscriptions
-- Library configs
-- Network requests


getCart : Effect Msg
getCart =
    Effect.protectedQuery
        { query = Query.cartV1 ssCart
        , onResponse = GotCartResponse
        }


getPickupPoints : Effect Msg
getPickupPoints =
    Effect.publicQuery
        { query = Query.pickupPointsV1 ssPickupPoint
        , onResponse = GotPickupPointsResponse
        }



-- Msg, update


type Msg
    = GotCartResponse (GraphqlResult Cart)
    | GotPickupPointsResponse (GraphqlResult (List PickupPoint))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GotCartResponse res ->
            ( { model | cart = RemoteData.fromResult res }, Effect.none )

        GotPickupPointsResponse res ->
            ( { model | pickupPoints = RemoteData.fromResult res }, Effect.none )



-- View


view : Model -> View Msg
view model =
    { title = "Cart"
    , attributes = []
    , element =
        column [ spacing 100 ] [ viewResponse viewCart model.cart, viewResponse viewPickupPoints model.pickupPoints ]
    }


viewCart : Cart -> Element Msg
viewCart cart =
    column [ spacing 50 ]
        [ column [ spacing 50 ] (List.map viewCartItem cart.items)
        , text <| "Total: " ++ UsdAmount.show cart.total
        ]


viewCartItem : CartItem -> Element Msg
viewCartItem item =
    row [ spacing 50 ]
        [ text <| item.product.title
        , text <| UsdPrice.show item.product.price
        , text <| String.fromInt item.quantity
        , text <| UsdAmount.show item.itemTotal
        ]


viewPickupPoints : List PickupPoint -> Element Msg
viewPickupPoints pickupPoints =
    column []
        [ text "Pickup points"
        , column [] (List.map viewPickupPoint pickupPoints)
        ]


viewPickupPoint : PickupPoint -> Element Msg
viewPickupPoint pickupPoint =
    row [] [ text <| pickupPoint.title ]
