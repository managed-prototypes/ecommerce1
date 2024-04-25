module Common.Time exposing (TimeZoneArgs, showAsUtc, showWithoutTimeZone, timeZoneUtc)

import Time


type alias TimeZoneArgs =
    { zoneName : String, zone : Time.Zone }


timeZoneUtc : TimeZoneArgs
timeZoneUtc =
    { zoneName = "UTC", zone = Time.utc }


showAsUtc : Time.Posix -> String
showAsUtc =
    showWithTimeZone timeZoneUtc


showWithTimeZone : TimeZoneArgs -> Time.Posix -> String
showWithTimeZone timeZoneArgs t =
    showWithoutTimeZone timeZoneArgs t
        ++ " "
        ++ timeZoneArgs.zoneName


showWithoutTimeZone : TimeZoneArgs -> Time.Posix -> String
showWithoutTimeZone { zone } t =
    padNumber2 (Time.toDay zone t)
        ++ "."
        ++ padNumber2 (Time.toMonth zone t |> monthToNumber)
        ++ "."
        ++ String.fromInt (Time.toYear zone t)
        ++ " "
        ++ padNumber2 (Time.toHour zone t)
        ++ ":"
        ++ padNumber2 (Time.toMinute zone t)
        ++ ":"
        ++ padNumber2 (Time.toSecond zone t)


padNumber2 : Int -> String
padNumber2 =
    String.fromInt >> String.padLeft 2 '0'


monthToNumber : Time.Month -> Int
monthToNumber m =
    case m of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12
