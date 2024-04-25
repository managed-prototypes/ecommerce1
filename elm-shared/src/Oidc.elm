module Oidc exposing
    ( AuthConfig
    , AuthEffects
    , Flow(..)
    , ZitadelAuthSuccess
    , ZitadelRefreshSuccess
    , authStateDecoder
    , authStateEncoder
    , authenticatedStateDecoder
    , extractIdTokenClaims
    , fromConfig
    , gotAuthStateFromLocalStorage
    , gotAuthStateFromLocalStorageProtected
    , gotRandomBytes
    , gotRefreshResponse
    , gotTokens
    , initAuth
    , refreshRequested
    , roleAdministrator
    , showError
    , showIdTokenClaims
    , signInRequested
    , signOutRequested
    , switchUserRequested
    , toAuthSuccess
    )

import Base64.Decode
import Base64.Encode as Base64
import Bytes exposing (Bytes)
import Bytes.Encode as Bytes
import Common.Duration as Duration exposing (Duration)
import Common.Time exposing (showAsUtc)
import Dict exposing (Dict)
import Http
import Json.Decode
import Json.Decode.Extra
import Json.Encode
import Json.Encode.Extra
import Maybe.Extra
import OAuth
import OAuth.AuthorizationCode.PKCE as OAuth
import Time
import Url exposing (Url)
import Url.Builder as Builder


type Flow
    = Idle
    | Authorized
    | Authenticated ZitadelAuthSuccess
    | Errored Error


toAuthSuccess : Flow -> Maybe ZitadelAuthSuccess
toAuthSuccess flow =
    case flow of
        Authenticated authSuccess ->
            Just authSuccess

        _ ->
            Nothing


{-| TODO: Add permissions and don't reset auth state on insufficient permissions to open the route.
-}
type Error
    = ErrStateMismatch
    | ErrFailedToConvertBytes
    | ErrAuthorization OAuth.AuthorizationError
    | ErrAuthentication OAuth.AuthenticationError
    | ErrHTTPGetAccessToken


showError : Error -> String
showError e =
    case e of
        ErrStateMismatch ->
            "'state' doesn't match, the request has likely been forged by an adversary!"

        ErrFailedToConvertBytes ->
            "Unable to convert bytes to 'state' and 'codeVerifier', this is likely not your fault..."

        ErrAuthorization error ->
            showOauthError { error = error.error, errorDescription = error.errorDescription }

        ErrAuthentication error ->
            showOauthError { error = error.error, errorDescription = error.errorDescription }

        ErrHTTPGetAccessToken ->
            "Unable to retrieve token: HTTP request failed."


showOauthError : { error : OAuth.ErrorCode, errorDescription : Maybe String } -> String
showOauthError { error, errorDescription } =
    let
        desc : String
        desc =
            errorDescription |> Maybe.withDefault "" |> String.replace "+" " "
    in
    OAuth.errorCodeToString error ++ ": " ++ desc


type alias AuthConfig =
    { authorizationEndpoint : Url
    , tokenEndpoint : Url
    , endSessionEndpoint : Url
    , clientId : String
    , scope : List String
    }


type alias VendorConfiguration =
    { paths :
        { authorization : String
        , token : String
        , endSession : String
        }
    , scope : List String
    }


zitadelConfiguration : VendorConfiguration
zitadelConfiguration =
    { paths =
        { authorization = "/oauth/v2/authorize"
        , token = "/oauth/v2/token"
        , endSession = "/oidc/v1/end_session"
        }
    , scope =
        [ "openid"
        , "profile"

        -- Required to get the refresh token
        , "offline_access"

        -- Adds all user roles
        , "urn:zitadel:iam:org:projects:roles"

        -- Without project:id:zitadel:aud you can't
        -- - get information about the user directly in zitadel
        -- - get user roles
        -- (Zitadel docs say it's intentional, but I don't really get the idea...)
        , "urn:zitadel:iam:org:project:id:zitadel:aud"
        ]
    }


fromConfig : Url -> String -> AuthConfig
fromConfig authBaseUrl authClientId =
    { authorizationEndpoint = { authBaseUrl | path = zitadelConfiguration.paths.authorization }
    , tokenEndpoint = { authBaseUrl | path = zitadelConfiguration.paths.token }
    , endSessionEndpoint = { authBaseUrl | path = zitadelConfiguration.paths.endSession }
    , clientId = authClientId

    {- The scope field will be very convenient to overwrite on the already created AuthConfig record.
       This way you can reuse the Oidc module for applications that require different scopes.
    -}
    , scope = zitadelConfiguration.scope
    }


bearerTokenToString : OAuth.Token -> String
bearerTokenToString =
    OAuth.tokenToString >> String.dropLeft 7


extractTokenClaimsString : String -> Maybe String
extractTokenClaimsString =
    String.split "."
        >> List.tail
        >> Maybe.andThen List.head
        >> Maybe.andThen (Base64.Decode.decode Base64.Decode.string >> Result.toMaybe)


convertBytes : List Int -> Maybe { state : String, codeVerifier : OAuth.CodeVerifier }
convertBytes bytes =
    if List.length bytes < (cSTATE_SIZE + cCODE_VERIFIER_SIZE) then
        Nothing

    else
        let
            mCodeVerifier : Maybe OAuth.CodeVerifier
            mCodeVerifier =
                bytes
                    |> List.drop cSTATE_SIZE
                    |> toBytes
                    |> OAuth.codeVerifierFromBytes
        in
        Maybe.map
            (\codeVerifier ->
                let
                    state : String
                    state =
                        bytes
                            |> List.take cSTATE_SIZE
                            |> toBytes
                            |> base64
                in
                { state = state, codeVerifier = codeVerifier }
            )
            mCodeVerifier


toBytes : List Int -> Bytes
toBytes =
    List.map Bytes.unsignedInt8 >> Bytes.sequence >> Bytes.encode


base64 : Bytes -> String
base64 =
    Base64.bytes >> Base64.encode


{-| Number of bytes making the 'state'
-}
cSTATE_SIZE : Int
cSTATE_SIZE =
    8


{-| Number of bytes making the 'code\_verifier'
-}
cCODE_VERIFIER_SIZE : Int
cCODE_VERIFIER_SIZE =
    32



-- ============================== ZITADEL


type alias ZitadelAuthSuccess =
    { accessToken : OAuth.Token
    , refreshToken : OAuth.Token
    , idToken : JwtToken -- we use it differently, and without the Bearer prefix
    , expiresIn : Duration
    }


{-| See dev-decisions.md for details
-}
authStateToFlow : Maybe ZitadelAuthSuccess -> Flow
authStateToFlow x =
    case x of
        Just authSuccess ->
            Authenticated authSuccess

        Nothing ->
            Idle


{-| For LocalStorage, See dev-decisions.md for details
-}
authStateDecoder : Json.Decode.Decoder (Maybe ZitadelAuthSuccess)
authStateDecoder =
    Json.Decode.oneOf
        [ Json.Decode.Extra.doubleEncoded <| Json.Decode.map Just authenticatedStateDecoder
        , Json.Decode.succeed Nothing
        ]


{-| For LocalStorage
-}
authenticatedStateDecoder : Json.Decode.Decoder ZitadelAuthSuccess
authenticatedStateDecoder =
    Json.Decode.map4 ZitadelAuthSuccess
        (Json.Decode.field "accessToken" bearerTokenDecoder)
        (Json.Decode.field "refreshToken" bearerTokenDecoder)
        (Json.Decode.field "idToken" idTokenDecoder)
        (Json.Decode.field "expiresIn" expiresInDecoder)


bearerTokenDecoder : Json.Decode.Decoder OAuth.Token
bearerTokenDecoder =
    (Json.Decode.string |> Json.Decode.map Just)
        |> Json.Decode.map (OAuth.makeToken (Just "bearer"))
        |> Json.Decode.andThen (decoderFromJust "missing or invalid 'access_token' / 'token_type'")


{-| For LocalStorage
-}
authStateEncoder : Maybe ZitadelAuthSuccess -> Json.Encode.Value
authStateEncoder =
    Json.Encode.Extra.maybe
        (\x ->
            Json.Encode.object
                [ ( "accessToken", Json.Encode.string <| bearerTokenToString x.accessToken )
                , ( "refreshToken", Json.Encode.string <| bearerTokenToString x.refreshToken )
                , ( "idToken"
                  , Json.Encode.string <|
                        case x.idToken of
                            JwtToken str ->
                                str
                  )
                , ( "expiresIn", Json.Encode.int <| Duration.toMillis x.expiresIn )
                ]
        )


type alias ZitadelRefreshSuccess =
    { accessToken : OAuth.Token
    , refreshToken : OAuth.Token
    , idToken : JwtToken -- we use it differently, and without the Bearer prefix
    , expiresIn : Duration
    }


type JwtToken
    = JwtToken String


unwrapJwtToken : JwtToken -> String
unwrapJwtToken (JwtToken x) =
    x


decoderFromJust : String -> Maybe a -> Json.Decode.Decoder a
decoderFromJust msg =
    Maybe.map Json.Decode.succeed >> Maybe.withDefault (Json.Decode.fail msg)


accessTokenDecoder : Json.Decode.Decoder OAuth.Token
accessTokenDecoder =
    Json.Decode.andThen (decoderFromJust "missing or invalid 'access_token' / 'token_type'") <|
        Json.Decode.map2 OAuth.makeToken
            (Json.Decode.field "token_type" Json.Decode.string |> Json.Decode.map Just)
            (Json.Decode.field "access_token" Json.Decode.string |> Json.Decode.map Just)


refreshTokenDecoder : Json.Decode.Decoder OAuth.Token
refreshTokenDecoder =
    Json.Decode.andThen (decoderFromJust "missing or invalid 'access_token' / 'token_type'") <|
        Json.Decode.map2 OAuth.makeToken
            (Json.Decode.field "token_type" Json.Decode.string |> Json.Decode.map Just)
            (Json.Decode.field "refresh_token" Json.Decode.string |> Json.Decode.map Just)


idTokenDecoder : Json.Decode.Decoder JwtToken
idTokenDecoder =
    Json.Decode.string |> Json.Decode.map JwtToken


expiresInDecoder : Json.Decode.Decoder Duration
expiresInDecoder =
    Json.Decode.int |> Json.Decode.map Duration.fromSeconds


zitadelAuthSuccessDecoder : Json.Decode.Decoder ZitadelAuthSuccess
zitadelAuthSuccessDecoder =
    Json.Decode.map4 ZitadelAuthSuccess
        accessTokenDecoder
        refreshTokenDecoder
        (Json.Decode.field "id_token" idTokenDecoder)
        (Json.Decode.field "expires_in" expiresInDecoder)


zitadelRefreshSuccessDecoder : Json.Decode.Decoder ZitadelRefreshSuccess
zitadelRefreshSuccessDecoder =
    Json.Decode.map4 ZitadelRefreshSuccess
        accessTokenDecoder
        refreshTokenDecoder
        (Json.Decode.field "id_token" idTokenDecoder)
        (Json.Decode.field "expires_in" expiresInDecoder)



-- {
--   "iss": "http://localhost:8091",
--   "sub": "224139274302259204",
--   "aud": [
--     "220047952645783557@ecommerce1",
--     "220048679334117381@ecommerce1",
--     "224594873293012996@ecommerce1",
--     "220047653491179525"
--   ],
--   "exp": 1690432627,
--   "iat": 1690389427,
--   "auth_time": 1690389037,
--   "amr": [
--     "password",
--     "pwd"
--   ],
--   "azp": "220047952645783557@ecommerce1",
--   "client_id": "220047952645783557@ecommerce1",
--   "at_hash": "96-9tGunoAvqXSanwmQM-g",
--   "c_hash": "SzCPr6LwwHDlQw5oveBVDw"
-- }
--
-- Admin:
-- {
--   "amr": ["password", "pwd"],
--   "at_hash": "BNZcr3riXk7hZuAkbw-07A",
--   "aud": [
--     "220047952645783557@ecommerce1",
--     "220048679334117381@ecommerce1",
--     "224594873293012996@ecommerce1",
--     "220047653491179525"
--   ],
--   "auth_time": 1690393428,
--   "azp": "220047952645783557@ecommerce1",
--   "c_hash": "ZCWAjBHHw9P1Ib7fLRiG6g",
--   "client_id": "220047952645783557@ecommerce1",
--   "exp": 1690486070,
--   "iat": 1690442870,
--   "iss": "http://localhost:8091",
--   "sub": "224139347719356420",
--   "urn:zitadel:iam:org:project:220047653491179525:roles": {
--     "moderator": {
--       "220047571165380613": "ecommerce1.localhost"
--     }
--   },
--   "urn:zitadel:iam:org:project:roles": {
--     "moderator": {
--       "220047571165380613": "ecommerce1.localhost"
--     }
--   }
-- }


type alias IdTokenClaims =
    { iss : String -- who issued token
    , sub : String -- subject (user id)
    , aud : List String -- where the user can go (all apps + something from Zitadel)
    , exp : Time.Posix -- when the token expires
    , iat : Time.Posix -- when the token was issued
    , authTime : Time.Posix -- when Zitadel checked the password
    , roles : Dict RoleName (Dict String String)
    }


type alias RoleName =
    String


roleAdministrator : RoleName
roleAdministrator =
    "administrator"


rolesDecoder : Json.Decode.Decoder (Dict RoleName (Dict String String))
rolesDecoder =
    Json.Decode.oneOf
        [ Json.Decode.field "urn:zitadel:iam:org:project:roles" <|
            Json.Decode.dict (Json.Decode.dict Json.Decode.string)
        , Json.Decode.succeed Dict.empty
        ]


showIdTokenClaims : IdTokenClaims -> List ( String, String )
showIdTokenClaims x =
    [ ( "iss", x.iss )
    , ( "sub", x.sub )
    ]
        ++ List.map (\aud -> ( "aud", aud ))
            x.aud
        ++ [ ( "exp", showAsUtc x.exp )
           , ( "iat", showAsUtc x.iat )
           , ( "authTime", showAsUtc x.authTime )
           , ( "roles:", String.join ", " (Dict.keys x.roles) )
           ]


jwtTimestampDecoder : Json.Decode.Decoder Time.Posix
jwtTimestampDecoder =
    Json.Decode.map (\expSeconds -> Time.millisToPosix (expSeconds * 1000)) Json.Decode.int


decodeIdTokenClaims : Json.Decode.Decoder IdTokenClaims
decodeIdTokenClaims =
    Json.Decode.map7 IdTokenClaims
        (Json.Decode.field "iss" Json.Decode.string)
        (Json.Decode.field "sub" Json.Decode.string)
        (Json.Decode.field "aud" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "exp" jwtTimestampDecoder)
        (Json.Decode.field "iat" jwtTimestampDecoder)
        (Json.Decode.field "auth_time" jwtTimestampDecoder)
        rolesDecoder


extractIdTokenClaims : JwtToken -> Maybe IdTokenClaims
extractIdTokenClaims (JwtToken str) =
    extractTokenClaimsString str
        |> Maybe.andThen (Json.Decode.decodeString decodeIdTokenClaims >> Result.toMaybe)


hasRole : RoleName -> JwtToken -> Bool
hasRole roleName =
    extractIdTokenClaims
        -- Note: It might make sense to decode roles directly into ZitadelAuthSuccess.
        -- But this may not be the case, because roles are not required in the webapp.
        >> Maybe.andThen (.roles >> Dict.get roleName)
        >> Maybe.Extra.isJust



-- Init


initAuth :
    AuthEffects msg effect
    ->
        { clearUrlEffect : effect
        , randBytes : Maybe (List Int)
        , persistedAuthState : Maybe ZitadelAuthSuccess
        , currentlyRequestedUrl : Url
        , backFromZitadelUrl : Url
        , persistedRequestedUrl : Maybe Url
        , authConfig : AuthConfig
        , tokensResponseToMsg : Result Http.Error ZitadelAuthSuccess -> msg
        , refreshResponseToMsg : Result Http.Error ZitadelRefreshSuccess -> msg
        }
    -> { flow : Flow, previouslyRequestedUrl : Maybe Url, authEffect : effect }
initAuth effect { clearUrlEffect, randBytes, persistedAuthState, currentlyRequestedUrl, backFromZitadelUrl, persistedRequestedUrl, authConfig, tokensResponseToMsg, refreshResponseToMsg } =
    case persistedAuthState of
        Just authState ->
            { flow = Authenticated authState
            , previouslyRequestedUrl = Nothing
            , authEffect =
                getTokensViaRefreshToken authConfig
                    { responseToMsg = refreshResponseToMsg, refreshToken = authState.refreshToken }
                    |> effect.sendCmd
            }

        Nothing ->
            case OAuth.parseCode currentlyRequestedUrl of
                OAuth.Empty ->
                    { flow = Idle
                    , previouslyRequestedUrl = Nothing
                    , authEffect =
                        effect.batch
                            [ effect.storeRequestedUrl (Just currentlyRequestedUrl)
                            , effect.signIn
                            ]
                    }

                -- It is important to set a `state` when making the authorization request
                -- and to verify it after the redirection. The state can be anything but its primary
                -- usage is to prevent cross-site request forgery; at minima, it should be a short,
                -- non-guessable string, generated on the fly.
                --
                -- We remember any previously generated state using the browser's local storage
                -- and give it back (if present) to the elm application upon start
                OAuth.Success { code, state } ->
                    let
                        oauthArgs : Maybe { state : String, codeVerifier : OAuth.CodeVerifier }
                        oauthArgs =
                            Maybe.andThen convertBytes randBytes
                    in
                    case oauthArgs of
                        Nothing ->
                            { flow = Errored ErrStateMismatch
                            , previouslyRequestedUrl = Nothing
                            , authEffect = effect.switchUser
                            }

                        Just authInitStuff ->
                            if state /= Just authInitStuff.state then
                                { flow = Errored ErrStateMismatch
                                , previouslyRequestedUrl = Nothing
                                , authEffect = effect.switchUser
                                }

                            else
                                { flow = Authorized
                                , previouslyRequestedUrl = persistedRequestedUrl
                                , authEffect =
                                    effect.batch
                                        [ effect.storeRequestedUrl Nothing
                                        , getTokensViaCode authConfig
                                            { backFromZitadelUrl = backFromZitadelUrl
                                            , code = code
                                            , codeVerifier = authInitStuff.codeVerifier
                                            , tokensResponseToMsg = tokensResponseToMsg
                                            }
                                            |> effect.sendCmd
                                        , clearUrlEffect
                                        ]
                                }

                OAuth.Error error ->
                    { flow = Errored <| ErrAuthorization error
                    , previouslyRequestedUrl = Nothing
                    , authEffect = effect.switchUser
                    }



-- Network requests


getTokensViaCode :
    AuthConfig
    ->
        { backFromZitadelUrl : Url
        , code : OAuth.AuthorizationCode
        , codeVerifier : OAuth.CodeVerifier
        , tokensResponseToMsg : Result Http.Error ZitadelAuthSuccess -> msg
        }
    -> Cmd msg
getTokensViaCode { clientId, tokenEndpoint } { backFromZitadelUrl, code, codeVerifier, tokensResponseToMsg } =
    Http.request <|
        OAuth.makeTokenRequestWith
            OAuth.AuthorizationCode
            zitadelAuthSuccessDecoder
            Dict.empty
            tokensResponseToMsg
            { credentials =
                { clientId = clientId
                , secret = Nothing
                }
            , code = code
            , codeVerifier = codeVerifier
            , url = tokenEndpoint
            , redirectUri = backFromZitadelUrl
            }


getTokensViaRefreshToken :
    AuthConfig
    ->
        { refreshToken : OAuth.Token
        , responseToMsg : Result Http.Error ZitadelRefreshSuccess -> msg
        }
    -> Cmd msg
getTokensViaRefreshToken { clientId, tokenEndpoint } { refreshToken, responseToMsg } =
    let
        body : String
        body =
            [ Builder.string "client_id" clientId
            , Builder.string "grant_type" (OAuth.grantTypeToString OAuth.RefreshToken)
            , Builder.string "refresh_token" (bearerTokenToString refreshToken)
            ]
                |> Builder.toQuery
                |> String.dropLeft 1
    in
    Http.request
        { method = "POST"
        , headers = []
        , url = Url.toString tokenEndpoint
        , body = Http.stringBody "application/x-www-form-urlencoded" body
        , expect = Http.expectJson responseToMsg zitadelRefreshSuccessDecoder
        , timeout = Nothing
        , tracker = Nothing
        }



-- Reusable update functions


type alias CompatibleModel m =
    { m
        | backFromZitadelUrl : Url
        , flow : Flow
        , authConfig : AuthConfig
    }


type alias AuthEffects msg effect =
    { none : effect
    , batch : List effect -> effect
    , sendCmd : Cmd msg -> effect
    , signIn : effect
    , switchUser : effect
    , loadExternalUrl : String -> effect

    -- custom effects
    , storeAuthState : Maybe ZitadelAuthSuccess -> effect
    , storeRequestedUrl : Maybe Url -> effect
    }


gotAuthStateFromLocalStorage :
    AuthEffects msg effect
    ->
        { maybeAuthSuccess : Maybe ZitadelAuthSuccess
        , navigateToRequestedPage : effect
        }
    -> CompatibleModel m
    -> ( CompatibleModel m, effect )
gotAuthStateFromLocalStorage effect { maybeAuthSuccess, navigateToRequestedPage } model =
    ( { model | flow = authStateToFlow maybeAuthSuccess }
    , case ( model.flow, maybeAuthSuccess ) of
        -- Reacquisition of tokens as a result of refresh on the current tab or on another tab
        ( Authenticated _, Just _ ) ->
            effect.none

        -- Transition from unauthorized to authorized state
        ( _, Just _ ) ->
            navigateToRequestedPage

        -- Transition from any state to unauthorized
        ( _, Nothing ) ->
            effect.none
    )


gotAuthStateFromLocalStorageProtected :
    AuthEffects msg effect
    ->
        { maybeAuthSuccess : Maybe ZitadelAuthSuccess
        , navigateToRequestedPage : effect
        , requireRole : RoleName
        }
    -> CompatibleModel m
    -> ( CompatibleModel m, effect )
gotAuthStateFromLocalStorageProtected effect { maybeAuthSuccess, navigateToRequestedPage, requireRole } model =
    let
        updatedModel : CompatibleModel m
        updatedModel =
            { model | flow = authStateToFlow maybeAuthSuccess }
    in
    case ( model.flow, maybeAuthSuccess ) of
        -- Reacquisition of tokens as a result of refresh on the current tab or on another tab
        ( Authenticated _, Just { idToken } ) ->
            if hasRole requireRole idToken then
                ( updatedModel, effect.none )

            else
                ( model, effect.switchUser )

        -- Transition from unauthorized to authorized state
        ( _, Just { idToken } ) ->
            if hasRole requireRole idToken then
                ( updatedModel, navigateToRequestedPage )

            else
                ( model, effect.switchUser )

        -- Transition from any state to unauthorized
        ( _, Nothing ) ->
            ( updatedModel, effect.none )


signInRequested :
    AuthEffects msg effect
    -> (Int -> Cmd msg)
    -> CompatibleModel m
    -> ( CompatibleModel m, effect )
signInRequested effect genRandomBytes model =
    case model.flow of
        Idle ->
            ( { model | flow = Idle }
              -- We generate random bytes for both the state and the code verifier. First bytes are
              -- for the 'state', and remaining ones are used for the code verifier.
            , genRandomBytes (cSTATE_SIZE + cCODE_VERIFIER_SIZE)
                |> effect.sendCmd
            )

        _ ->
            ( model, effect.none )


gotRandomBytes :
    AuthEffects msg effect
    -> List Int
    -> CompatibleModel m
    -> ( CompatibleModel m, effect )
gotRandomBytes effect bytes model =
    case model.flow of
        Idle ->
            case convertBytes bytes of
                Nothing ->
                    ( { model | flow = Errored ErrFailedToConvertBytes }
                    , effect.switchUser
                    )

                Just { state, codeVerifier } ->
                    let
                        authorization : OAuth.Authorization
                        authorization =
                            { clientId = model.authConfig.clientId
                            , redirectUri = model.backFromZitadelUrl
                            , scope = model.authConfig.scope
                            , state = Just state
                            , codeChallenge = OAuth.mkCodeChallenge codeVerifier
                            , url = model.authConfig.authorizationEndpoint
                            }
                    in
                    ( { model | flow = Idle }
                    , authorization
                        |> OAuth.makeAuthorizationUrl
                        |> Url.toString
                        |> effect.loadExternalUrl
                    )

        _ ->
            ( model, effect.none )


gotTokens :
    AuthEffects msg effect
    -> Result Http.Error ZitadelAuthSuccess
    -> CompatibleModel m
    -> ( CompatibleModel m, effect )
gotTokens effect authenticationResponse model =
    case model.flow of
        Authorized ->
            case authenticationResponse of
                Err (Http.BadBody body) ->
                    case Json.Decode.decodeString OAuth.defaultAuthenticationErrorDecoder body of
                        Ok error ->
                            ( { model | flow = Errored <| ErrAuthentication error }, effect.switchUser )

                        _ ->
                            ( { model | flow = Errored ErrHTTPGetAccessToken }, effect.switchUser )

                Err _ ->
                    ( { model | flow = Errored ErrHTTPGetAccessToken }, effect.switchUser )

                -- We won't update flow here, but wait for it to update in the LocalStorage.
                Ok authSuccess ->
                    ( model
                    , effect.storeAuthState <| Just authSuccess
                    )

        _ ->
            ( model, effect.none )


refreshRequested :
    AuthEffects msg effect
    -> (Result Http.Error ZitadelRefreshSuccess -> msg)
    -> CompatibleModel m
    -> ( CompatibleModel m, effect )
refreshRequested effect responseToMsg model =
    case model.flow of
        Authenticated { refreshToken } ->
            ( model
            , getTokensViaRefreshToken model.authConfig
                { responseToMsg = responseToMsg, refreshToken = refreshToken }
                |> effect.sendCmd
            )

        _ ->
            ( model, effect.none )


gotRefreshResponse :
    AuthEffects msg effect
    -> Result Http.Error ZitadelRefreshSuccess
    -> CompatibleModel m
    -> ( CompatibleModel m, effect )
gotRefreshResponse effect refreshResponse model =
    case model.flow of
        Authenticated _ ->
            case refreshResponse of
                Err (Http.BadBody body) ->
                    case Json.Decode.decodeString OAuth.defaultAuthenticationErrorDecoder body of
                        Ok error ->
                            ( { model | flow = Errored <| ErrAuthentication error }, effect.switchUser )

                        _ ->
                            ( { model | flow = Errored ErrHTTPGetAccessToken }, effect.switchUser )

                Err _ ->
                    ( { model | flow = Errored ErrHTTPGetAccessToken }, effect.switchUser )

                Ok refreshSuccess ->
                    let
                        updated : ZitadelAuthSuccess
                        updated =
                            { accessToken = refreshSuccess.accessToken
                            , refreshToken = refreshSuccess.refreshToken
                            , idToken = refreshSuccess.idToken
                            , expiresIn = refreshSuccess.expiresIn
                            }
                    in
                    ( { model | flow = Authenticated updated }
                    , effect.storeAuthState <| Just updated
                    )

        _ ->
            ( model, effect.none )


switchUserRequested :
    AuthEffects msg effect
    -> CompatibleModel m
    -> ( CompatibleModel m, effect )
switchUserRequested effect model =
    ( { model | flow = Idle }
    , effect.batch
        [ effect.storeAuthState <| Nothing
        , effect.signIn
        ]
    )


signOutRequested :
    AuthEffects msg effect
    -> CompatibleModel m
    -> ( CompatibleModel m, effect )
signOutRequested effect model =
    case model.flow of
        Authenticated { idToken } ->
            let
                postLogoutRedirectUrl : Url
                postLogoutRedirectUrl =
                    { protocol = model.backFromZitadelUrl.protocol
                    , host = model.backFromZitadelUrl.host
                    , port_ = model.backFromZitadelUrl.port_
                    , path = ""
                    , query = Nothing
                    , fragment = Nothing
                    }

                query : String
                query =
                    [ Builder.string "id_token_hint" (unwrapJwtToken idToken)
                    , Builder.string "post_logout_redirect_uri" (Url.toString postLogoutRedirectUrl)
                    ]
                        |> Builder.toQuery
                        |> String.dropLeft 1

                endSessionUrl : Url
                endSessionUrl =
                    { protocol = model.authConfig.endSessionEndpoint.protocol
                    , host = model.authConfig.endSessionEndpoint.host
                    , port_ = model.authConfig.endSessionEndpoint.port_
                    , path = model.authConfig.endSessionEndpoint.path
                    , query = Just query
                    , fragment = Nothing
                    }
            in
            ( { model | flow = Idle }
            , effect.batch
                [ effect.storeAuthState <| Nothing
                , effect.loadExternalUrl <| Url.toString endSessionUrl
                ]
            )

        _ ->
            ( model, effect.none )
