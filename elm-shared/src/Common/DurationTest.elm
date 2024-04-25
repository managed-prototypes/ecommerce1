module Common.DurationTest exposing (suite)

import Common.Duration as Duration exposing (Duration(..), TimeUnits, fromTimeUnits, toTimeUnits)
import Expect
import Fuzz exposing (Fuzzer)
import Random exposing (Generator)
import Test exposing (Test, describe, fuzz, test)


durationFuzzer : Fuzzer Duration
durationFuzzer =
    let
        generator : Generator Duration
        generator =
            Random.map
                DurationMillis
                (Random.int 0 (10 * 365 * 24 * 3600000))
    in
    Fuzz.fromGenerator generator


durationRepFuzzer : Fuzzer TimeUnits
durationRepFuzzer =
    let
        generator : Generator TimeUnits
        generator =
            Random.map5
                (\days hours minutes seconds millis -> { days = days, hours = hours, minutes = minutes, seconds = seconds, millis = millis })
                (Random.int 0 <| 10 * 365)
                (Random.int 0 23)
                (Random.int 0 59)
                (Random.int 0 59)
                (Random.int 0 999)
    in
    Fuzz.fromGenerator generator


suite : Test
suite =
    describe "Duration"
        [ describe "fromTimeUnits, toTimeUnits"
            [ fuzz durationRepFuzzer "roundtrip fromTimeUnits >> toTimeUnits" <|
                \randomDurationRep ->
                    randomDurationRep
                        |> fromTimeUnits
                        |> toTimeUnits
                        |> Expect.equal randomDurationRep
            , fuzz durationFuzzer "roundtrip toTimeUnits >> fromTimeUnits" <|
                \randomDuration ->
                    randomDuration
                        |> toTimeUnits
                        |> fromTimeUnits
                        |> Expect.equal randomDuration
            , describe "roundtrip constructors"
                [ test "fromDays" <|
                    \() ->
                        Duration.fromDays 1
                            |> toTimeUnits
                            |> fromTimeUnits
                            |> Expect.equal (Duration.fromDays 1)
                , test "fromHours" <|
                    \() ->
                        Duration.fromHours 1
                            |> toTimeUnits
                            |> fromTimeUnits
                            |> Expect.equal (Duration.fromHours 1)
                , test "fromMinutes" <|
                    \() ->
                        Duration.fromMinutes 1
                            |> toTimeUnits
                            |> fromTimeUnits
                            |> Expect.equal (Duration.fromMinutes 1)
                , test "fromSeconds" <|
                    \() ->
                        Duration.fromSeconds 1
                            |> toTimeUnits
                            |> fromTimeUnits
                            |> Expect.equal (Duration.fromSeconds 1)
                , test "fromMillis" <|
                    \() ->
                        Duration.fromMillis 1
                            |> toTimeUnits
                            |> fromTimeUnits
                            |> Expect.equal (Duration.fromMillis 1)
                ]
            ]
        ]
