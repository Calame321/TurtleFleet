local Page = require( "turtlefleet.ui.components.page" )
local Panel = require( "turtlefleet.ui.components.panel" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )
local BackButton = require( "turtlefleet.ui.components.back_button" )
local Title = require( "turtlefleet.ui.components.title" )

local DigOutPage = Page:new()
local selector = Selector:new():set_focus( true )
local lbl_depth = Label:new( "16", 15, 3 )
local lbl_width = Label:new( "16", 15, 4 )

local depth = 16
local width = 16

local function start_dig_out()
  turtle.dig_out( depth, width )
end

local function add_depth()
  width = width + 1
  lbl_width:set_text( tostring( width ) )
end

local function sub_depth()
  width = math.max( 1, width - 1 )
  lbl_width:set_text( tostring( width ) )
end

local function add_width()
  depth = depth + 1
  lbl_depth:set_text( tostring( depth ) )
end

local function sub_width()
  depth = math.max( 1, depth - 1 )
  lbl_depth:set_text( tostring( depth ) )
end

selector
  :add_component( Label:new( " Start", 3, 3 ):set_func( function() start_dig_out() end, { keys.l } ) )
  :add_component( Label:new( "+", 14, 8 ):set_func( add_width ) )
  :add_component( Label:new( "-", 21, 8 ):set_func( sub_width ) )
  :add_component( Label:new( "+", 14, 9 ):set_func( add_depth ) )
  :add_component( Label:new( "-", 21, 9 ):set_func( sub_depth ) )
DigOutPage
  :add_component( Title:new( "Dig Out", string.char( 186 ), colors.black ) )
  :add_component( BackButton:new( "miner/miner_page" ) )
  :add_component( selector )
  :add_component( Panel:new( 3, 6, 20, 5 ):set_title( "Settings:" ):border( true ):set_color( colors.lightBlue )
    :add_component( Label:new( "Depth:", 2, 3 ) )
    :add_component( Label:new( "Width:", 2, 4 ) )
    :add_component( lbl_width )
    :add_component( lbl_depth )
  )
return DigOutPage

--[[
  This will dig a 3 blocks high area the size you specify.
  It's recomended to set some storages before if you can.
]]