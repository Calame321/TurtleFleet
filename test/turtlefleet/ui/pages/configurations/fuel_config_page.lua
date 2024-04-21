local Page = require( "turtlefleet.ui.components.page" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )
local BackButton = require( "turtlefleet.ui.components.back_button" )
local ItemList = require( "turtlefleet.ui.components.item_list" )
local Title = require( "turtlefleet.ui.components.title" )

local FuelPage = Page:new()
local option_selector = Selector:new()
local refuel_all_lbl = Label:new( string.char( 164 ) .. " Refuel all", 2, 5 )
local back_btn = BackButton:new( "configurations/configurations_page", 1, 1 )
local item_list = ItemList:new():set_back_btn( back_btn )

local function valid_fuel_selected()
  item_list:enable()
  option_selector:set_focus( false )
end

local function set_refuel_all()
  local c = string.char( 42 )
  if turtle.refuel_all then c = string.char( 7 ) end
  refuel_all_lbl:set_text( c .. " Refuel all" )
end

local function refuel_all_selected()
  TSettingsManager.set_refuel_all( (not turtle.refuel_all) )
  set_refuel_all()
end

--- When an item is added to the list.
local function on_data_added()
  return function( data )
    TSettingsManager.set_valid_fuel( data )
  end
end

local function done_adding_items()
  return function()
    item_list:disable()
    option_selector:set_focus( true )
  end
end

--- Add the item from the selected turtle slot.
local function on_add_selected_slot_clicked()
  return function()
    local item = turtle.getItemDetail()
    if item then
      item_list:add_data( item.name )
    end
  end
end

item_list
  :add_option( Label:new( " " .. string.char( 169 ) .. " selected slot", 2, 4 ):set_func( on_add_selected_slot_clicked() ) )
  :add_option( Label:new( " " .. string.char( 27 ) .. " Done", 2, 5 ):set_func( done_adding_items() ) )
option_selector:set_focus( true )
  :add_component( Label:new( "- Valid Fuel", 2, 4 ):set_func( valid_fuel_selected ) )
  :add_component( refuel_all_lbl:set_func( refuel_all_selected ) )
FuelPage
  :add_component( Title:new( "Fuel Config", string.char( 21 ), colors.black ) )
  :add_component( Label:new( "Options:", 2, 3 ) )
  :add_component( option_selector )
  :add_component( back_btn )
  :add_component( item_list:on_data_added( on_data_added() ) )

item_list:disable()
item_list:set_data( turtle.valid_fuel )
set_refuel_all()
return FuelPage

--[[
  print( "- Valid Fuel -" )
  print( "A turtle can consume any fuel a furnace can burn." )

  print( "- Refuel All -" )
  print( "Do you want your turtle to eat a full stack of fuel when it needs it?" )

]]