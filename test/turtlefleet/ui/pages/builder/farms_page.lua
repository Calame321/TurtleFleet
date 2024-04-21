local Page = require( "turtlefleet.ui.components.page" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )

local FarmsPage = Page:new()
local folder = "builder/farms/"
FarmsPage:add_component( Label:new( "Menu -> Stations -> Farms", 2, 3 ) )
  :add_component( Label:new( "Choose a farm:", 2, 5 ) )
  :add_component( Selector:new():set_focus( true )
    :add_component( Label:new( "1 - Farmer's Delight: Rice", 2, 6 ):set_func( function() print( "harvester.rice_farm" ) end, { keys.one } ) )
    :add_component( Label:new( "2 - Minecraft: Sugar Cane", 2, 7 ):set_func( Page:change_to( folder .. "cane_farm" ), { keys.two } ) ) )
    :add_component( Label:new( string.char( 27 ) .. "Back", 1, 1 ):set_bg( colors.blue ):set_fg( colors.white ):set_func( Page:change_to( "stations_page" ), { keys.b } ) )
return FarmsPage
