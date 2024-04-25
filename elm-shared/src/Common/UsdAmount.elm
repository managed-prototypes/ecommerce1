module Common.UsdAmount exposing (UsdAmount, decodeString, encodeString, show)

{-| The value of this type is guaranteed to

  - be non-negative
  - have cents < 100

Otherwise, it won't be decoded.

-}


type UsdAmount
    = UsdAmount { dollars : Int, cents : Int }


show : UsdAmount -> String
show (UsdAmount { dollars, cents }) =
    "$" ++ String.fromInt dollars ++ "." ++ (String.fromInt cents |> String.padRight 2 '0')


encodeString : UsdAmount -> String
encodeString (UsdAmount { dollars, cents }) =
    String.fromInt dollars ++ "." ++ String.fromInt cents


decodeString : String -> Maybe UsdAmount
decodeString str =
    case String.split "." str of
        [ dollars, cents ] ->
            case ( String.toInt dollars, String.toInt cents ) of
                ( Just d, Just c ) ->
                    if c < 100 then
                        Just <| UsdAmount { dollars = d, cents = c }

                    else
                        Nothing

                _ ->
                    Nothing

        _ ->
            Nothing
