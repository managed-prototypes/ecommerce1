module ScalarCodecs exposing (Timestamp, Unit, UsdAmount, UsdPrice, codecs)

import Api.Scalar
import Common.UsdAmount as UsdAmount
import Common.UsdPrice as UsdPrice
import Json.Decode as Decode
import Json.Decode.Extra
import Json.Encode as Encode
import Time


type alias UsdPrice =
    UsdPrice.UsdPrice


type alias UsdAmount =
    UsdAmount.UsdAmount


type alias Unit =
    ()


type alias Timestamp =
    Time.Posix


codecs : Api.Scalar.Codecs Timestamp Unit UsdAmount UsdPrice
codecs =
    Api.Scalar.defineCodecs
        { codecTimestamp =
            { encoder = \posixTime -> Time.posixToMillis posixTime |> String.fromInt |> Encode.string
            , decoder =
                Decode.string
                    |> Decode.andThen
                        (\str ->
                            case String.toInt str of
                                Just x ->
                                    Decode.succeed <| Time.millisToPosix x

                                Nothing ->
                                    Decode.fail "Expected UNIX timestamp in millis, but got something else"
                        )
            }
        , codecUnit =
            { encoder = \() -> Encode.string ""
            , decoder =
                Decode.string
                    |> Decode.andThen
                        (\str ->
                            case str of
                                "" ->
                                    Decode.succeed ()

                                _ ->
                                    Decode.fail "Expected an empty string"
                        )
            }
        , codecUsdAmount =
            { encoder = UsdAmount.encodeString >> Encode.string
            , decoder =
                Decode.string
                    |> Decode.andThen (UsdAmount.decodeString >> Json.Decode.Extra.fromMaybe "Invalid USD amount")
            }
        , codecUsdPrice =
            { encoder = UsdPrice.encodeString >> Encode.string
            , decoder =
                Decode.string
                    |> Decode.andThen (UsdPrice.decodeString >> Json.Decode.Extra.fromMaybe "Invalid USD price")
            }
        }
