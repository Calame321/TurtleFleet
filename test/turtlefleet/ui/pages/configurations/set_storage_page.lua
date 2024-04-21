local Page = require( "turtlefleet.ui.components.page" )
local Selector = require( "turtlefleet.ui.components.selector" )
local InventoryGrid = require( "turtlefleet.ui.components.inventory_grid" )
local Label = require( "turtlefleet.ui.components.label" )
local ItemList = require( "turtlefleet.ui.components.item_list" )
local BackButton = require( "turtlefleet.ui.components.back_button" )

local StoragePage = Page:new()
local type_selector = Selector:new():set_focus( true )
local inventory_grid = InventoryGrid:new( 4, 9 )
local storage_colors = { colors.gray, colors.lime, colors.orange }
local back_btn = BackButton:new( "configurations/configurations_page" )
local item_list = ItemList:new()
  :set_back_btn( back_btn )

--- Change the color for the inventory grid.
local function on_select_changed()
  inventory_grid:set_color( storage_colors[ type_selector.current_index ] )
end

local function type_selected()
  type_selector:set_focus( false )
  inventory_grid:set_focus( true )
  inventory_grid:blink( true )
end

local function inventory_index_changed()
  return function( index )
    if turtle.storage[ index ] and turtle.storage[ index ].type == turtle.FILTERED_DROP_STORAGE then
      item_list:clear()
      item_list:set_data( turtle.storage[ index ].filtered_items )
    else
      item_list:clear()
    end
  end
end

--- When an inventory cell is selected.
--- If it's a simple storage, nothing special happens.
--- If it's a filtered storage, enable the item list.
local function inventory_cell_selected()
  inventory_grid:set_focus( false )
  if inventory_grid:is_cell_empty( inventory_grid.selected_index ) then
    TSettingsManager.remove_storage( inventory_grid.selected_index )
    type_selector:set_focus( true )
  else
    if type_selector.current_index == 3 then
      item_list:enable()
    else
      inventory_grid:enable()
      type_selector:set_focus( true )
      local new_storage = { type = type_selector.current_index }
      TSettingsManager.set_storage( inventory_grid.selected_index, new_storage )
    end
  end
end

--- When a block is added to the list.
local function on_data_added()
  return function( data )
    local new_storage = { type = type_selector.current_index }
    new_storage.filtered_items = data
    TSettingsManager.set_storage( inventory_grid.selected_index, new_storage )
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

--- Done option selected.
local function done_adding_items()
  return function()
    item_list:disable()
    type_selector:set_focus( true )
  end
end

item_list
  :add_option( Label:new( " " .. string.char( 169 ) .. " selected slot", 2, 4 ):set_func( on_add_selected_slot_clicked() ) )
  :add_option( Label:new( " " .. string.char( 27 ) .. " Done", 2, 5 ):set_func( done_adding_items() ) )
type_selector
  :add_component( Label:new( " Fuel", 5, 4 ):set_func( type_selected, { keys.f } ) )
  :add_component( Label:new( " Drop", 5, 5 ):set_func( type_selected, { keys.d } ) )
  :add_component( Label:new( " Filtered", 5, 6 ):set_func( type_selected, { keys.i } ) )
StoragePage
  :add_component( Label:new( "- Storage -", 1, 1, term.width, 1 ):set_bg( colors.blue ):set_fg( colors.white ) )
  :add_component( Label:new( string.char( 169 ), 13, 1 ):set_bg( colors.blue ):set_fg( colors.orange ) )
  :add_component( Label:new( string.char( 169 ), 27, 1 ):set_bg( colors.blue ):set_fg( colors.orange ) )
  :add_component( back_btn )
  :add_component( item_list:on_data_added( on_data_added() ) )
  :add_component( Label:new( "Types:", 1, 3 ) )
  :add_component( Label:new( string.char( 143 ), 2, 4 ):set_fg( colors.gray ) )
  :add_component( Label:new( string.char( 143 ), 2, 5 ):set_fg( colors.lime ) )
  :add_component( Label:new( string.char( 143 ), 2, 6 ):set_fg( colors.orange ) )
  :add_component( inventory_grid:set_color( storage_colors[ 1 ] ):on_selected( inventory_cell_selected ):on_index_changed( inventory_index_changed() ) )
  :add_component( type_selector:on_changed( on_select_changed ) )
  :add_component( Label:new( "Inventory:", 1, 8 ) )

item_list:disable()

-- Load current storages.
local storages = TSettingsManager.get( "storage" )
for k, v in pairs( storages ) do
  inventory_grid:set_color( storage_colors[ v.type ] )
  inventory_grid:set_cell_color( k )
end

return StoragePage


--[[ 
"Here you can give a storage that maintain it's content when broken, like a ShulkerBox, to the turtle."
  print( "1: The turtle will pick fuel from it." )
  print( "2: It will drop it's inventory in the storage when full." )
  print( "3: Filtered, can be used to drop item in a trash or a special storage." )
]]