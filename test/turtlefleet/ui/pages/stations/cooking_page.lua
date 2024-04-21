local Page = require( "turtlefleet.ui.components.page" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )
local BackButton = require( "turtlefleet.ui.components.back_button" )
local Title = require( "turtlefleet.ui.components.title" )

local TreeFarmPage = Page:new()
local selector = Selector:new():set_focus( true )

local function build()
  
end

selector
  :add_component( Label:new( "Build", 3, 3 ):set_func( build, { keys.s } ) )
TreeFarmPage
  :add_component( Title:new( "Cooking Station", string.char( 219 ), colors.orange ) )
  :add_component( BackButton:new( "stations/stations_page", 1, 1 ) )
  :add_component( selector )
return TreeFarmPage
--[[
  The turtle will build the stuff and you'll need to right click the modems...
]]