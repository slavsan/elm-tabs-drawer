port module Main exposing (..)

import Browser
import Html exposing (Html, Attribute, a, li, ul, button, div, span, i, img, table, tbody, tr, td, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Svg.Attributes as SvgAttr
import Url


-- MAIN


main =
  Browser.element
      { init = init
      , update = update
      , subscriptions = subscriptions
      , view = view
      }


-- MODEL


type ActiveTab = AllTabs
               | TabsByDomain
               | TabsByGroup
               | SavedTabs
               | Settings

type alias Model =
  { tabs : Tabs
  , activeTab : ActiveTab
  , savedTabs : SavedTabs
  }

type alias Tab =
  { id : Int
  , url : String
  , favIconUrl : String
  , title : String
  , active : Bool
  , pinned : Bool
  , audible : Bool
  , muted : Bool
  }

type alias Tabs = List Tab

type alias GroupOfTabsByDomain =
  { domain : String
  , tabs : Tabs
  }

type alias GroupsOfTabsByDomain = List GroupOfTabsByDomain

type alias SavedTab =
  { url : String
  , title : String
  , favIconUrl : String
  }

type alias SavedTabs = List SavedTab

port openApp : Bool -> Cmd msg

port tabs : (Tabs -> msg) -> Sub msg

port savedTabs : (SavedTabs -> msg) -> Sub msg

port openTab : Int -> Cmd msg

port closeTab : Int -> Cmd msg

port bulkCloseTab : List Int -> Cmd msg

port saveTab : SavedTab -> Cmd msg

port togglePin : Int -> Cmd msg

port toggleMute : Int -> Cmd msg

init : () -> (Model, Cmd Msg)
init _ =
  ( { tabs = []
    , activeTab = AllTabs
    , savedTabs = []
    }
  , Cmd.none
  )


-- UPDATE


type Msg = OpenApp
         | ReceivedTabs Tabs
         | ReceivedSavedTabs SavedTabs
         | OpenTab Tab
         | CloseTab Tab
         | BulkCloseTab Tabs
         | TogglePin Tab
         | ToggleMute Tab
         | SelectTab ActiveTab
         | SaveTab SavedTab

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    OpenApp ->
      ( model
      , openApp True
      )

    ReceivedTabs receivedTabs ->
      ( { model | tabs = receivedTabs }
      , Cmd.none
      )

    ReceivedSavedTabs receivedSavedTabs ->
      ( { model | savedTabs = receivedSavedTabs }
      , Cmd.none
      )

    OpenTab tab ->
      ( model
      , openTab tab.id
      )

    CloseTab tab ->
      ( model
      , closeTab tab.id
      )

    BulkCloseTab tabList ->
      ( model
      , bulkCloseTab (idsOnly tabList)
      )

    TogglePin tab ->
      ( model
      , togglePin tab.id
      )

    ToggleMute tab ->
      ( model
      , toggleMute tab.id
      )

    SelectTab tab ->
      ( { model | activeTab = tab }
      , Cmd.none
      )

    SaveTab tab ->
      ( model
      , saveTab tab
      )


-- VIEW


view : Model -> Html Msg
view model =
  div [ class "container" ]
    [ viewNavigationTabs model
    , viewActiveTab model
    ]

viewTabList : Tabs -> Html Msg
viewTabList tabList =
  table [ class "table" ]
    [ tabList
        |> List.map viewTab
        |> tbody []
    ]

toSavedTab : Tab -> SavedTab
toSavedTab tab =
  { url = tab.url
  , title = tab.title
  , favIconUrl = tab.favIconUrl
  }

viewTab : Tab -> Html Msg
viewTab tab =
  tr []
    [ td [] [ button
                [ classList
                    [ ("button", True)
                    , ("is-small", True)
                    , ("is-white", True)
                    , ("is-primary", tab.pinned == True)
                    , ("has-text-grey", tab.pinned /= True)
                    ]
                , onClick (TogglePin tab)
                ]
                [ viewIcon "thumbtack"
                ]
            ]
    , td [] [ button
                [ classList
                    [ ("button", True)
                    , ("is-small", True)
                    , ("is-white", True)
                    , ("is-primary", tab.audible == True)
                    , ("has-text-grey", tab.audible == False)
                    ]
                , onClick (ToggleMute tab)
                ]
                [ viewIcon (audioIcon tab)
                ]
            ]
    , td [] [ button
                [ classList
                    [ ("button", True)
                    , ("is-small", True)
                    , ("is-white", True)
                    , ("has-text-grey", True)
                    ]
                , onClick (CloseTab tab)
                ]
                [ viewIcon "trash"
                ]
            ]
    , td [] [ button
                [ classList
                    [ ("button", True)
                    , ("is-small", True)
                    , ("is-white", True)
                    , ("has-text-grey", True)
                    ]
                , onClick (SaveTab (toSavedTab tab))
                ]
                [ viewIcon "save"
                ]
            ]
    , td [] [ button
                [ classList
                    [ ("button", True)
                    , ("is-small", True)
                    , ("is-white", True)
                    , ("has-text-grey", True)
                    ]
                ]
                [ viewIcon "lock-open"
                ]
            ]
    , td [] [ button
                [ classList
                    [ ("button", True)
                    , ("is-small", True)
                    , ("is-white", True)
                    , ("has-text-grey", True)
                    ]
                , onClick (OpenTab tab)
                ]
                [ viewIcon "arrow-alt-circle-right"
                ]
            ]
    , td [ class "favicon-col" ] [ viewFavicon tab.favIconUrl ]
    , td [] [ span [] [ text tab.title ] ]
    ]

audioIcon : Tab -> String
audioIcon tab =
  if not tab.audible && tab.muted then
    "volume-mute"
  else if not tab.audible && not tab.muted then
    "volume-off"
  else if tab.audible && tab.muted then
    "volume-mute"
  else
    "volume-up"

viewIcon : String -> Html Msg
viewIcon icon =
  span
    [ classList
        [ ("icon", True)
        , ("is-small", True)
        ]
    ]
    [ i [ SvgAttr.class ("fas " ++ ("fa-" ++ icon))
        ]
        []
    ]

isActive : ActiveTab -> Model -> String
isActive tab model =
  if tab == model.activeTab then
    "is-active"
  else
    ""

viewNavigationTabs : Model -> Html Msg
viewNavigationTabs model =
  div [ class "tabs is-centered" ]
    [ ul []
        [ li [ class (isActive AllTabs model) ]
            [ a [ onClick (SelectTab AllTabs) ] [ text "All tabs" ] ]
        , li [ class (isActive TabsByDomain model)  ]
            [ a [ onClick (SelectTab TabsByDomain) ] [ text "Tabs by domain" ] ]
        , li [ class (isActive TabsByGroup model)  ]
            [ a [ onClick (SelectTab TabsByGroup) ] [ text "Tabs by group" ] ]
        , li [ class (isActive SavedTabs model)  ]
            [ a [ onClick (SelectTab SavedTabs) ] [ text "Saved" ] ]
        , li [ class (isActive Settings model)  ]
            [ a [ onClick (SelectTab Settings) ] [ text "Settings" ] ]
        ]
    ]

idsOnly : Tabs -> List Int
idsOnly tabList =
  List.map (\x -> x.id) tabList

hasMember : String -> GroupsOfTabsByDomain -> Bool
hasMember domain list =
  List.length (List.filter (\x -> x.domain == domain) list) > 0

addTabToGroup : GroupsOfTabsByDomain -> String -> Tab -> GroupsOfTabsByDomain
addTabToGroup list host tab =
  let
    updateGroup group =
      if group.domain == host then
        { domain = group.domain
        , tabs = tab :: group.tabs
        }
      else
        group
  in
    List.map updateGroup list

groupTabsByDomain : Tab -> GroupsOfTabsByDomain -> GroupsOfTabsByDomain
groupTabsByDomain tab list =
  let
    url = Url.fromString tab.url
    host = case url of
             Nothing ->
               "chrome://"

             Just url_ ->
               url_.host
  in
    if hasMember host list then
      addTabToGroup list host tab
    else
      { domain = host, tabs = [tab] } :: list

viewGroupsOfTabsByDomain : GroupsOfTabsByDomain -> Html Msg
viewGroupsOfTabsByDomain groups =
  groups
    |> List.map viewGroupOfTabByDomain
    |> div []

viewGroupOfTabByDomain : GroupOfTabsByDomain -> Html Msg
viewGroupOfTabByDomain group =
  div []
    [ div []
        [ span [] [ text group.domain ]
        , button [ onClick (BulkCloseTab group.tabs) ] [ text "close all" ]
        ]
    , viewTabList group.tabs
    ]

viewSavedTab : SavedTab -> Html Msg
viewSavedTab savedTab =
  div []
    [ viewFavicon savedTab.favIconUrl
    , span [] [ text (savedTab.title ++ " - " ++ savedTab.url) ]
    ]

viewActiveTab : Model -> Html Msg
viewActiveTab model =
  case model.activeTab of
    AllTabs ->
      div []
        [ viewTabCount model.tabs
        , viewTabList model.tabs
        ]

    TabsByDomain ->
      let
        groups =
          List.foldl
            groupTabsByDomain
            []
            model.tabs
      in
        [groups]
          |> List.map viewGroupsOfTabsByDomain
          |> div []

    TabsByGroup ->
      div [] [ text "tabs by group" ]

    SavedTabs ->
      div []
        [ model.savedTabs
            |> List.map viewSavedTab
            |> div []
        ]

    Settings ->
      div [] [ text "settings" ]

viewFavicon : String -> Html Msg
viewFavicon favIconUrl =
  img [ src favIconUrl
      , class "favicon"
      , width 16
      , height 16
      ]
    []

viewTabCount : Tabs -> Html Msg
viewTabCount tabList =
  div []
    [ text ("open tabs: " ++ (String.fromInt (List.length tabList))) ]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
    [ tabs ReceivedTabs
    , savedTabs ReceivedSavedTabs
    ]
