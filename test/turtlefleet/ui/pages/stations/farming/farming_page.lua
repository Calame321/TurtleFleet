local Page = require( "turtlefleet.ui.components.page" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )
local BackButton = require( "turtlefleet.ui.components.back_button" )
local Title = require( "turtlefleet.ui.components.title" )

local farmingPage = Page:new()
local folder = "stations/farming/"
farmingPage
  :add_component( Title:new( "Farms", string.char( 127 ), colors.orange ) )
  :add_component( Label:new( "Menu -> Stations -> Farms", 2, 3 ) )
  :add_component( BackButton:new( "stations/stations_page" ) )
  :add_component( Label:new( "Choose a farm:", 2, 5 ) )
  :add_component( Selector:new():set_focus( true )
    :add_component( Label:new( "1 - Farmer's Delight: Rice", 2, 6 ):set_func( Page:change_to( folder .. "rice_page" ), { keys.one } ) )
    :add_component( Label:new( "2 - Minecraft: Sugar Cane", 2, 7 ):set_func( Page:change_to( folder .. "sugarcane_page" ), { keys.two } ) ) )
    :add_component( Label:new( string.char( 27 ) .. "Back", 1, 1 ):set_bg( colors.blue ):set_fg( colors.white ):set_func( Page:change_to( "stations/stations_page" ), { keys.b } ) )
return farmingPage
