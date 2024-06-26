-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.CartItem exposing (..)

import Api.InputObject
import Api.Interface
import Api.Object
import Api.Scalar
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode
import ScalarCodecs


product :
    SelectionSet decodesTo Api.Object.Product
    -> SelectionSet decodesTo Api.Object.CartItem
product object____ =
    Object.selectionForCompositeField "product" [] object____ Basics.identity


quantity : SelectionSet Int Api.Object.CartItem
quantity =
    Object.selectionForField "Int" "quantity" [] Decode.int


itemTotal : SelectionSet ScalarCodecs.UsdAmount Api.Object.CartItem
itemTotal =
    Object.selectionForField "ScalarCodecs.UsdAmount" "itemTotal" [] (ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecUsdAmount |> .decoder)
