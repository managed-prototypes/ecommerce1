module Common.UsdPrice exposing
    ( UsdPrice
    , decodeString
    , decodeUserInput
    , encodeString
    , show
    , toUserInput
    )

{-| The value of this type is guaranteed to

  - be non-negative
  - have cents < 100

Otherwise, it won't be decoded.

-}


type UsdPrice
    = UsdPrice { dollars : Int, cents : Int }


show : UsdPrice -> String
show (UsdPrice { dollars, cents }) =
    "$" ++ String.fromInt dollars ++ "." ++ (String.fromInt cents |> String.padRight 2 '0')


{-| Use this function to prefill text inputs with a valid UsdPrice.
-}
toUserInput : UsdPrice -> String
toUserInput (UsdPrice { dollars, cents }) =
    String.fromInt dollars ++ "." ++ (String.fromInt cents |> String.padRight 2 '0')


{-| Currently, the implementation is the same, but it could become different in the future.
-}
decodeUserInput : String -> Maybe UsdPrice
decodeUserInput =
    decodeString


encodeString : UsdPrice -> String
encodeString (UsdPrice { dollars, cents }) =
    String.fromInt dollars ++ "." ++ String.fromInt cents


decodeString : String -> Maybe UsdPrice
decodeString str =
    case String.split "." str of
        [ dollars, cents ] ->
            case ( String.toInt dollars, String.toInt cents ) of
                ( Just d, Just c ) ->
                    if c < 100 then
                        Just <| UsdPrice { dollars = d, cents = c }

                    else
                        Nothing

                _ ->
                    Nothing

        _ ->
            Nothing
