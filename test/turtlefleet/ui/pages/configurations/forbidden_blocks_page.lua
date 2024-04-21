local Page = require( "turtlefleet.ui.components.page" )
local ItemList = require( "turtlefleet.ui.components.item_list" )
local BackButton = require( "turtlefleet.ui.components.back_button" )
local Title = require( "turtlefleet.ui.components.title" )
local Label = require( "turtlefleet.ui.components.label" )

local ForbiddenBlocksPage = Page:new()
local back_btn = BackButton:new( "configurations/configurations_page" )
local item_list = ItemList:new( 1, 2, term.width ):set_back_btn( back_btn )

--- When an item is added to the list.
local function on_data_added()
  return function( data )
    TSettingsManager.set_forbidden_block( data )
  end
end

--- Add the block in front of the turtle.
---@return function
local function on_add_block_selected()
  return function()
    local success, block = turtle.inspect( turtle.FORWARD )
    if success then
      item_list:add_data( block.name )
    end
  end
end

item_list
  :add_option( Label:new( " " .. string.char( 169 ) .. " Front of Turtle", 2, 4 ):set_func( on_add_block_selected() ) )
ForbiddenBlocksPage
  :add_component( Title:new( "Forbidden Blocks", string.char( 19 ), colors.red ) )
  :add_component( back_btn )
  :add_component( item_list:on_data_added( on_data_added() ) )

item_list:enable()
item_list:set_data( turtle.forbidden_block )
return ForbiddenBlocksPage

--[[
  print( "- Forbidden -" )
  print( "Blocks that the turtle should not mine! Used if you want to mine diamond ore with fortune or for stuff that can explode." )
  print( "Enter block name or place it in front of the turtle then press enter." )
  print( "*same to remove it." )
  
  -- if the input is empty, try to get the block in front
  if input == "" then
    local has_block, block_data = turtle.inspect()

    if has_block then
      input = block_data.name
    end
  end

  -- if input not empty, add the new block
  if input ~= "" then
    turtle.add_or_remove_forbidden_block( input )
  end
]]