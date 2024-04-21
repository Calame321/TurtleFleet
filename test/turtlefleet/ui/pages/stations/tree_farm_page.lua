local Page = require( "turtlefleet.ui.components.page" )
local Panel = require( "turtlefleet.ui.components.panel" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )
local BackButton = require( "turtlefleet.ui.components.back_button" )
local Title = require( "turtlefleet.ui.components.title" )

local TreeFarmPage = Page:new()
local selector = Selector:new():set_focus( true )
local lbl_farm_length = Label:new( "15", 7, 3 )

local farm_length = 15

local function start_farm()
  
end

local function add_length()
  farm_length = farm_length + 1
  lbl_farm_length:set_text( tostring( farm_length ) )
end

local function sub_length()
  farm_length = math.max( 1, farm_length - 1 )
  lbl_farm_length:set_text( tostring( farm_length ) )
end

selector
  :add_component( Label:new( "Start", 3, 3 ):set_func( start_farm, { keys.s } ) )
  :add_component( Label:new( "+", 4, 7 ):set_func( add_length, { keys.a } ) )
  :add_component( Label:new( "-", 15, 7 ):set_func( sub_length, { keys.minus } ) )
TreeFarmPage
  :add_component( Title:new( "Tree Farm", string.char( 6 ), colors.lime ) )
  :add_component( BackButton:new( "stations/stations_page", 1, 1 ) )
  :add_component( selector )
  :add_component( Panel:new( 3, 5, 14, 4 ):set_title( "Farm Length:" ):border( true ):set_color( colors.lightBlue )
    :add_component( lbl_farm_length )
  )

return TreeFarmPage
--[[
  print( "The turtle will plant trees and harvest them. It will also cook its own fuel." )
  lumberjack.start( tree_farm_length )
]]