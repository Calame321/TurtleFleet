local Page = require( "turtlefleet.ui.components.page" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )
local Title = require( "turtlefleet.ui.components.title" )
local BackButton = require( "turtlefleet.ui.components.back_button" )

local MinerPage = Page:new()
local folder = "miner/"
MinerPage
  :add_component( Title:new( "Miner", string.char( 29 ), colors.lightGray ) )
  :add_component( BackButton:new( "main_menu_page" ) )
  :add_component( Label:new( "Menu -> Miner", 2, 3 ) )
  :add_component( Label:new( "Choose a job:", 2, 5 ) )
  :add_component( Selector:new():set_focus( true )
    :add_component( Label:new( "1 - Dig Out", 2, 6 ):set_func( Page:change_to( folder .. "digout_page" ), { keys.one } ) )
    :add_component( Label:new( "2 - Flatten chunk", 2, 7 ):set_func( Page:change_to( folder .. "flatten_chunk_page" ), { keys.two } ) )
    :add_component( Label:new( "3 - Vein Mine", 2, 8 ):set_func( Page:change_to( folder .. "vein_mine_page" ), { keys.three } ) )
    :add_component( Label:new( "4 - Branch Mine", 2, 9 ):set_func( Page:change_to( folder .. "branch_mine_page" ), { keys.four } ) )
    :add_component( Label:new( "5 - Tunnel", 2, 10 ):set_func( function() print( folder .. "miner.dig_tunnel" ) end, { keys.five } ) ) )
return MinerPage
