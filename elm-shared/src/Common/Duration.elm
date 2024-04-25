module Common.Duration exposing
    ( Duration(..)
    , TimeUnits
    , between
    , every
    , fromDays
    , fromHours
    , fromMillis
    , fromMinutes
    , fromSeconds
    , fromTimeUnits
    , multiply
    , showDuration
    , showDurationShort
    , subtractFromPosix
    , toMillis
    , toTimeUnits
    )

import Basics.Extra exposing (safeIntegerDivide, safeRemainderBy)
import Time


type Duration
    = DurationMillis Int


type alias TimeUnits =
    { days : Int, hours : Int, minutes : Int, seconds : Int, millis : Int }


between : { beginTime : Time.Posix, endTime : Time.Posix } -> Duration
between { beginTime, endTime } =
    DurationMillis <| Time.posixToMillis endTime - Time.posixToMillis beginTime


every : Duration -> (Time.Posix -> msg) -> Sub msg
every =
    toMillis >> toFloat >> Time.every


toMillis : Duration -> Int
toMillis (DurationMillis millis) =
    millis


divRem : Int -> Int -> Maybe ( Int, Int )
divRem x d =
    case ( safeIntegerDivide x d, safeRemainderBy d x ) of
        ( Just a, Just b ) ->
            Just ( a, b )

        _ ->
            Nothing


multiply : Float -> Duration -> Duration
multiply factor =
    toMillis
        >> toFloat
        >> (*) factor
        >> round
        >> fromMillis


fromTimeUnits : TimeUnits -> Duration
fromTimeUnits { days, hours, minutes, seconds, millis } =
    DurationMillis <| (days * 24 * 3600000) + hours * 3600000 + minutes * 60000 + seconds * 1000 + millis


toTimeUnits : Duration -> TimeUnits
toTimeUnits (DurationMillis totalMillis) =
    let
        ( days, r1 ) =
            divRem totalMillis (24 * 3600000) |> Maybe.withDefault ( 0, 0 )

        ( hours, r2 ) =
            divRem r1 3600000 |> Maybe.withDefault ( 0, 0 )

        ( minutes, r3 ) =
            divRem r2 60000 |> Maybe.withDefault ( 0, 0 )

        ( seconds, millis ) =
            divRem r3 1000 |> Maybe.withDefault ( 0, 0 )
    in
    { days = days
    , hours = hours
    , minutes = minutes
    , seconds = seconds
    , millis = millis
    }


subtractFromPosix : Duration -> Time.Posix -> Time.Posix
subtractFromPosix (DurationMillis millis) time =
    Time.millisToPosix (Time.posixToMillis time - millis)


{-| Must be non-negative
-}
fromDays : Int -> Duration
fromDays x =
    fromTimeUnits <|
        { days = abs x
        , hours = 0
        , minutes = 0
        , seconds = 0
        , millis = 0
        }


{-| Must be non-negative
-}
fromHours : Int -> Duration
fromHours x =
    fromTimeUnits <|
        { days = 0
        , hours = abs x
        , minutes = 0
        , seconds = 0
        , millis = 0
        }


{-| Must be non-negative
-}
fromMinutes : Int -> Duration
fromMinutes x =
    fromTimeUnits <|
        { days = 0
        , hours = 0
        , minutes = abs x
        , seconds = 0
        , millis = 0
        }


{-| Must be non-negative
-}
fromSeconds : Int -> Duration
fromSeconds x =
    fromTimeUnits <|
        { days = 0
        , hours = 0
        , minutes = 0
        , seconds = abs x
        , millis = 0
        }


{-| Must be non-negative
-}
fromMillis : Int -> Duration
fromMillis x =
    fromTimeUnits <|
        { days = 0
        , hours = 0
        , minutes = 0
        , seconds = 0
        , millis = abs x
        }


showDuration : Duration -> String
showDuration =
    toTimeUnits >> showTimeUnits


showDurationShort : Duration -> String
showDurationShort =
    toTimeUnits >> showTimeUnitsShort


showTimeUnits : TimeUnits -> String
showTimeUnits { days, hours, minutes, seconds, millis } =
    let
        components : List ( Int, String )
        components =
            case [ days, hours, minutes, seconds ] of
                [ 0, 0, 0, 0 ] ->
                    [ ( millis, "millis" ) ]

                _ ->
                    [ ( days, "days" )
                    , ( hours, "hours" )
                    , ( minutes, "minutes" )
                    , ( seconds, "seconds" )
                    ]
    in
    components
        |> List.filter (Tuple.first >> (/=) 0)
        |> List.map (\( n, label ) -> String.fromInt n ++ " " ++ label)
        |> String.join ", "


showTimeUnitsShort : TimeUnits -> String
showTimeUnitsShort { days, hours, minutes, seconds, millis } =
    let
        components : List ( Int, String )
        components =
            case [ days, hours, minutes, seconds ] of
                [ 0, 0, 0, 0 ] ->
                    [ ( millis, "ms" ) ]

                _ ->
                    [ ( days, "d" )
                    , ( hours, "h" )
                    , ( minutes, "m" )
                    , ( seconds, "s" )
                    ]
    in
    components
        |> List.filter (Tuple.first >> (/=) 0)
        |> List.map (\( n, label ) -> String.fromInt n ++ label)
        |> String.join " "
