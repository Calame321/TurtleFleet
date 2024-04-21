local Page = require( "turtlefleet.ui.components.page" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )
local Title = require( "turtlefleet.ui.components.title" )

local MainMenu = Page:new()
MainMenu
  :add_component( Title:new( "Turtle Fleet: Turtle ", "", colors.white ) )
  :add_component( Label:new( "Menu", 2, 3 ) )
  :add_component( Label:new( "Choose an option:", 2, 5 ) )
  :add_component( Selector:new():set_focus( true )
    :add_component( Label:new( "1 - Stations", 2, 6 ):set_func( Page:change_to( "stations/stations_page" ), { keys.one } ) )
    :add_component( Label:new( "2 - Miner", 2, 7 ):set_func( Page:change_to( "miner/miner_page" ), { keys.two } ) )
    :add_component( Label:new( "3 - Builder", 2, 8 ):set_func( Page:change_to( "builder/builder_page" ), { keys.three } ) )
    :add_component( Label:new( "4 - Fleet Mode", 2, 9 ):set_func( Page:change_to( "fleet_mode/fleet_page" ), { keys.four } ) )
    :add_component( Label:new( "5 - Configurations", 2, 10 ):set_func( Page:change_to( "configurations/configurations_page" ), { keys.five } ) ) )
return MainMenu