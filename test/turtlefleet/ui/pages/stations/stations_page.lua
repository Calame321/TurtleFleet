local Page = require( "turtlefleet.ui.components.page" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )
local BackButton = require( "turtlefleet.ui.components.back_button" )
local Title = require( "turtlefleet.ui.components.title" )

local StationsPage = Page:new()
local folder = "stations/"
StationsPage
  :add_component( Title:new( "Stations", string.char( 4 ), colors.orange ) )
  :add_component( BackButton:new( "main_menu_page" ) )
  :add_component( Label:new( "Menu -> Stations", 2, 3 ) )
  :add_component( Label:new( "Choose a station:", 2, 5 ) )
  :add_component( Selector:new():set_focus( true )
    :add_component( Label:new( "1 - Tree Farm", 2, 6 ):set_func( Page:change_to( folder .. "tree_farm_page" ), { keys.one } ) )
    :add_component( Label:new( "2 - Cooking", 2, 7 ):set_func( Page:change_to( folder .. "cooking_page" ), { keys.two } ) )
    :add_component( Label:new( "3 - Farming", 2, 8 ):set_func( Page:change_to( folder .. "farming/farming_page" ), { keys.three } ) ) )
return StationsPage