local Page = require( "turtlefleet.ui.components.page" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )

local FleetPage = Page:new( 1, 2 )
FleetPage
  :add_component( Label:new( "Menu -> Builder", 2, 2 ) )
  :add_component( Label:new( "Choose a job:", 2, 4 ) )
  :add_component( Selector:new():set_focus( true )
    :add_component( Label:new( "1 - Fleet Dig Out", 2, 5 ):set_func( Page:change_to( "fleet_dig_out_page" ), { keys.one } ) )
    :add_component( Label:new( "2 - Fleet Flatten", 2, 6 ):set_func( Page:change_to( "fleet_flatten_page" ), { keys.two } ) )
    :add_component( Label:new( "3 - Fleet Manager", 2, 7 ):set_func( Page:change_to( "fleet_manager_page" ), { keys.three } ) ) )
  :add_component( Label:new( string.char( 27 ) .. "Back", 1, 0 ):set_bg( colors.blue ):set_fg( colors.white ):set_func( Page:change_to( "main_menu_page" ), { keys.b } ) )
return FleetPage
