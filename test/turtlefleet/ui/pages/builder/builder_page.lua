local Page = require( "turtlefleet.ui.components.page" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )

local BuilderPage = Page:new()
local folder = "builder/"
BuilderPage:add_component( Label:new( "Menu -> Builder", 2, 2 ) )
  :add_component( Label:new( "Choose a job:", 2, 4 ) )
  :add_component( Selector:new():set_focus( true )
    :add_component( Label:new( "1 - Place Floor", 2, 5 ):set_func( Page:change_to( folder .. "place_floor_page" ), { keys.one } ) )
    :add_component( Label:new( "2 - Place Ceiling", 2, 6 ):set_func( Page:change_to( folder .. "place_ceiling_page" ), { keys.two } ) )
    :add_component( Label:new( "3 - Place Wall", 2, 7 ):set_func( Page:change_to( folder .. "place_wall_page" ), { keys.three } ) ) )
  :add_component( Label:new( string.char( 27 ) .. "Back", 1, 0 ):set_bg( colors.blue ):set_fg( colors.white ):set_func( Page:change_to( "main_menu_page" ), { keys.b } ) )
return BuilderPage

