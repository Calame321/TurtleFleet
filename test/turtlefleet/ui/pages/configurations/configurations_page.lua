local Page = require( "turtlefleet.ui.components.page" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )
local BackButton = require( "turtlefleet.ui.components.back_button" )
local Title = require( "turtlefleet.ui.components.title" )

local ConfigurationPage = Page:new()
local folder = "configurations/"
ConfigurationPage
  :add_component( Title:new( "Settings", "#", colors.lightGray ) )
  :add_component( BackButton:new( "main_menu_page" ) )
  :add_component( Label:new( "Menu -> Settings", 2, 3 ) )
  :add_component( Label:new( "Choose an option:", 2, 5 ) )
  :add_component( Selector:new():set_focus( true )
    :add_component( Label:new( "1 - Installer", 2, 6 ):set_func( function() shell.run( "pastebin run TBpm1C8V" ) end, { keys.one } ) )
    :add_component( Label:new( "2 - Storage", 2, 7 ):set_func( Page:change_to( folder .. "set_storage_page" ), { keys.two } ) )
    :add_component( Label:new( "3 - Fuel", 2, 8 ):set_func( Page:change_to( folder .. "fuel_config_page" ), { keys.three } ) )
    :add_component( Label:new( "4 - Forbidden Block", 2, 9 ):set_func( Page:change_to( folder .. "forbidden_blocks_page" ), { keys.four } ) ) )
return ConfigurationPage
