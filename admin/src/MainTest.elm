module MainTest exposing (suite)

import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "arithmetics"
        [ test "addition works" <|
            \() ->
                2
                    + 2
                    |> Expect.equal 4
        ]
