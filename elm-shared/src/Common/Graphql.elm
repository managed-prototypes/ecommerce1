module Common.Graphql exposing
    ( GraphqlData
    , GraphqlError
    , GraphqlResult
    , MutationReq
    , ProtectedRequest
    , PublicRequest
    , QueryReq
    , mapProtectedRequest
    , mapPublicRequest
    , protectedMutation
    , protectedQuery
    , publicMutation
    , publicQuery
    , showGraphqlError
    , viewResponse
    )

import Element exposing (..)
import Graphql.Http as Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet
import OAuth
import RemoteData exposing (RemoteData(..))
import Task


{-| elm-graphql allows also to get some "possibly recovered data",
but we don't care, that's why we have a Unit type as a parameter to Error.
-}
type alias GraphqlError =
    Http.Error ()


{-| For Msg
-}
type alias GraphqlResult a =
    Result GraphqlError a


{-| For Model
-}
type alias GraphqlData a =
    RemoteData GraphqlError a


{-| For protected requests
-}
type alias ProtectedRequest msg =
    { graphqlUrl : String, token : OAuth.Token } -> Cmd msg


mapProtectedRequest : (msg1 -> msg2) -> ProtectedRequest msg1 -> ProtectedRequest msg2
mapProtectedRequest fn req =
    req >> Cmd.map fn


{-| For public requests
-}
type alias PublicRequest msg =
    { graphqlUrl : String } -> Cmd msg


mapPublicRequest : (msg1 -> msg2) -> PublicRequest msg1 -> PublicRequest msg2
mapPublicRequest fn req =
    req >> Cmd.map fn


type alias QueryReq a =
    SelectionSet.SelectionSet a RootQuery


publicQuery :
    { query : QueryReq a
    , onResponse : GraphqlResult a -> msg
    }
    -> PublicRequest msg
publicQuery { query, onResponse } { graphqlUrl } =
    query
        |> Http.queryRequest graphqlUrl
        |> Http.toTask
        |> Task.mapError (Http.mapError <| always ())
        |> Task.attempt onResponse


protectedQuery :
    { query : QueryReq a
    , onResponse : GraphqlResult a -> msg
    }
    -> ProtectedRequest msg
protectedQuery { query, onResponse } { graphqlUrl, token } =
    query
        |> Http.queryRequest graphqlUrl
        |> Http.withHeader "Authorization" (OAuth.tokenToString token)
        |> Http.toTask
        |> Task.mapError (Http.mapError <| always ())
        |> Task.attempt onResponse


type alias MutationReq a =
    SelectionSet.SelectionSet a RootMutation


publicMutation :
    { mutation : MutationReq a
    , onResponse : GraphqlResult a -> msg
    }
    -> PublicRequest msg
publicMutation { mutation, onResponse } { graphqlUrl } =
    mutation
        |> Http.mutationRequest graphqlUrl
        |> Http.toTask
        |> Task.mapError (Http.mapError <| always ())
        |> Task.attempt onResponse


protectedMutation :
    { mutation : MutationReq a
    , onResponse : GraphqlResult a -> msg
    }
    -> ProtectedRequest msg
protectedMutation { mutation, onResponse } { graphqlUrl, token } =
    mutation
        |> Http.mutationRequest graphqlUrl
        |> Http.withHeader "Authorization" (OAuth.tokenToString token)
        |> Http.toTask
        |> Task.mapError (Http.mapError <| always ())
        |> Task.attempt onResponse


{-| Naive helper for dev purposes
-}
viewResponse : (a -> Element msg) -> GraphqlData a -> Element msg
viewResponse view data =
    case data of
        NotAsked ->
            text "Not asked"

        Loading ->
            text "Loading"

        Failure e ->
            text <| "Failure: " ++ showGraphqlError e

        Success a ->
            view a


{-| Show error message from GraphqlResponse
-}
showGraphqlError : GraphqlError -> String
showGraphqlError err =
    case err of
        Http.HttpError Http.NetworkError ->
            "Network error"

        Http.HttpError (Http.BadUrl _) ->
            "BadUrl"

        Http.HttpError Http.Timeout ->
            "Timeout"

        Http.HttpError (Http.BadStatus _ _) ->
            "BadStatus"

        Http.HttpError (Http.BadPayload _) ->
            "BadStatus"

        Http.GraphqlError _ graphqlErrors ->
            List.map (\e -> e.message) graphqlErrors |> String.join ", "
