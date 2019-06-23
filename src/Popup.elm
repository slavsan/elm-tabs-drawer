port module Main exposing (..)

import Browser
import Html exposing (Html, Attribute, br, button, h2, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as E exposing (Value, int, object, string)


-- MAIN


main =
  Browser.element
      { init = init
      , update = update
      , subscriptions = subscriptions
      , view = view
      }


-- MODEL


type alias Model = {}

init : () -> (Model, Cmd Msg)
init _ =
  ( {}
  , Cmd.none
  )

port openApp : Bool -> Cmd msg


-- UPDATE


type Msg = OpenApp

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    OpenApp ->
      ( model
      , openApp True
      )


-- VIEW


view : Model -> Html Msg
view model =
  div [ class "popup" ]
    [ button
        [ classList
            [ ("button", True)
            , ("is-primary", True)
            ]
        , onClick OpenApp
        ]
        [ text "Open extension page" ]
    ]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch []
