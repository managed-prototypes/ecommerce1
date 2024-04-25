-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Mutation exposing (..)

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
import Json.Decode as Decode exposing (Decoder)
import ScalarCodecs


type alias AdminProductCreateV1RequiredArguments =
    { productInput : Api.InputObject.ProductInput }


adminProductCreateV1 :
    AdminProductCreateV1RequiredArguments
    -> SelectionSet ScalarCodecs.Unit RootMutation
adminProductCreateV1 requiredArgs____ =
    Object.selectionForField "ScalarCodecs.Unit" "adminProductCreateV1" [ Argument.required "productInput" requiredArgs____.productInput Api.InputObject.encodeProductInput ] (ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecUnit |> .decoder)


type alias AdminProductUpdateV1RequiredArguments =
    { productId : String
    , productInput : Api.InputObject.ProductInput
    }


adminProductUpdateV1 :
    AdminProductUpdateV1RequiredArguments
    -> SelectionSet ScalarCodecs.Unit RootMutation
adminProductUpdateV1 requiredArgs____ =
    Object.selectionForField "ScalarCodecs.Unit" "adminProductUpdateV1" [ Argument.required "productId" requiredArgs____.productId Encode.string, Argument.required "productInput" requiredArgs____.productInput Api.InputObject.encodeProductInput ] (ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecUnit |> .decoder)