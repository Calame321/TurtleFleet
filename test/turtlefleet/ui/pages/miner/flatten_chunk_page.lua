local Page = require( "turtlefleet.ui.components.page" )
local Panel = require( "turtlefleet.ui.components.panel" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )
local BackButton = require( "turtlefleet.ui.components.back_button" )
local Title = require( "turtlefleet.ui.components.title" )

local chunks = 1
local height = 5

local FlattenChunkPage = Page:new()
local selector = Selector:new():set_focus( true )
local lbl_chunks = Label:new( tostring( chunks ), 15, 3 )
local lbl_height = Label:new( tostring( height ), 15, 4 )

local function start_dig_out()
  turtle.dig_out( chunks, height )
end

local function add_depth()
  height = height + 1
  lbl_height:set_text( tostring( height ) )
end

local function sub_depth()
  height = math.max( 1, height - 1 )
  lbl_height:set_text( tostring( height ) )
end

local function add_width()
  chunks = chunks + 1
  lbl_chunks:set_text( tostring( chunks ) )
end

local function sub_width()
  chunks = math.max( 1, chunks - 1 )
  lbl_chunks:set_text( tostring( chunks ) )
end

selector
  :add_component( Label:new( " Start", 3, 3 ):set_func( function() start_dig_out() end, { keys.l } ) )
  :add_component( Label:new( "+", 14, 8 ):set_func( add_width ) )
  :add_component( Label:new( "-", 21, 8 ):set_func( sub_width ) )
  :add_component( Label:new( "+", 14, 9 ):set_func( add_depth ) )
  :add_component( Label:new( "-", 21, 9 ):set_func( sub_depth ) )
  :add_component( Label:new( "", 4, 10 ) )
  :add_component( Label:new( "", 4, 11 ) )
FlattenChunkPage
  :add_component( Title:new( "Flatten Chunk", string.char( 186 ), colors.black ) )
  :add_component( BackButton:new( "miner/miner_page" ) )
  :add_component( selector )
  :add_component( Panel:new( 3, 6, 20, 7 ):set_title( "Settings:" ):border( true ):set_color( colors.lightBlue )
    :add_component( Label:new( "Chunks:", 2, 3 ) )
    :add_component( Label:new( "Height:", 2, 4 ) )
    :add_component( Label:new( "x", 4, 5 ) )
    :add_component( Label:new( "x", 4, 5 ) )
    :add_component( Label:new( string.char( 164 ) .. " Dirt on water", 3, 5 ) )
    :add_component( Label:new( string.char( 7 ) .. " Dirt in empty", 3, 6 ) )
    :add_component( lbl_height )
    :add_component( lbl_chunks )
  )
return FlattenChunkPage

--[[
  print( "- Flatten Chunk (16 x 16) -" )
  print( "This will flatten a 16 by 16 area. (from the back left corner). The extra height is to prevent floating blocks." )
  print( "It's recomended to set some storages before if you can." )
  

  miner.start_flaten_chunks( nb_chunk, extra_height )
]]