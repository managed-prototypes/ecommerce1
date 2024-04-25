module Components.ProductEditor exposing (Handlers, Model, toProductInput, view)

import Api.InputObject exposing (ProductInput)
import Common.UsdPrice as UsdPrice
import Element exposing (..)
import Element.Input as Input
import Url


type alias Model model =
    { model
        | imageUrlInput : String
        , titleInput : String
        , priceInput : String
    }


type alias Handlers msg =
    { onImageUrlInputChanged : String -> msg
    , onTitleInputChanged : String -> msg
    , onPriceInputChanged : String -> msg
    }


toProductInput : Model model -> Maybe ProductInput
toProductInput model =
    Maybe.map2
        -- Note: we only validate the URL, but we don't need to use the parsed URL
        (\price _ ->
            { imageUrl = model.imageUrlInput
            , title = model.titleInput
            , price = price
            }
        )
        (UsdPrice.decodeUserInput model.priceInput)
        (Url.fromString model.imageUrlInput)


view : Model model -> Handlers msg -> Element msg
view model handlers =
    column [ spacing 20 ]
        [ image [ width (px 400), height (px 400) ] { src = model.imageUrlInput, description = model.titleInput }
        , Input.text []
            { onChange = handlers.onImageUrlInputChanged
            , text = model.imageUrlInput
            , placeholder = Just <| Input.placeholder [] (text "Image URL")
            , label = Input.labelHidden "Image URL"
            }
        , Input.text []
            { onChange = handlers.onTitleInputChanged
            , text = model.titleInput
            , placeholder = Just <| Input.placeholder [] (text "Title")
            , label = Input.labelHidden "Title"
            }
        , Input.text []
            { onChange = handlers.onPriceInputChanged
            , text = model.priceInput
            , placeholder = Just <| Input.placeholder [] (text "Price")
            , label = Input.labelHidden "Price"
            }
        ]
