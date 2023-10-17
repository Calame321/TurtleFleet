---@class StorageManager
---@field inventories Inventory[] All the known inventories.
local o = {}

o.inventories = {}
o.reserved_items = {}

--- Prepare a list so we can reserve items for crafting or building.
---@return integer reserve_id
function o.start_new_reserve()
  local reserve_id = math.random( 100000 )
  while table.contains( o.reserved_items ) do reserve_id = math.random( 100000 ) end
  o.reserved_items[ reserve_id ] = {}
  return reserve_id
end

--- Get all peripherals that has an inventory.
---@return table
function o.find_inventories()
  local inventories = {}
  for _, name in ipairs( peripheral.getNames() ) do
    if peripheral.hasType( name, "inventory" ) then
      table.insert( inventories, name )
    end
  end
  return inventories
end

--- Get the first available inventory.
---@return peripheral|nil # The peripheral that has the inventory.
function o.get_first_inventory()
  for _, name in ipairs( peripheral.getNames() ) do
    -- TODO: Only chest like inventory? not the furnaces and brewing stand etc...
    if peripheral.hasType( name, "inventory" ) then
      return peripheral.wrap( name )
    end
  end
  return nil
end

--- Find items matching the resource.
---@param resource Resource
---@return unknown|nil # Wrapped inventory peripheral.
---@return integer|nil # Index of the item in the inventory.
function o.find_resource( resource )
  for _, name in ipairs( peripheral.getNames() ) do
    if peripheral.hasType( name, "inventory" ) then
      for index, item in pairs( peripheral.call( name, "list" ) ) do
        if item.name == resource.item.name then
          return peripheral.wrap( name ), index
        elseif resource.item.tag then
          local item_detail = peripheral.call( name, "getItemDetail", index )
          if item_detail.tags[ resource.item.tag ] then
            return peripheral.wrap( name ), index
          end
        end
      end
    end
  end
  return nil, nil
end

--- Get the available quantity up to the amount desired for a resource and add it to a reserved list.
---@param resource Resource
---@param reserve_id integer
---@return integer # Quantity available.
function o.add_to_reserve( resource, reserve_id )
  assert( reserve_id, "The reserve id is nil!" )
  local qty_available = o.get_total( resource )
  local reserved_resource = resource:copy()
  table.insert( o.reserved_items[ reserve_id ], reserved_resource )
  CLogManager.log_debug( "qty_available: " .. qty_available )
  return qty_available
end

--- Clear the list of reserved items.
---@param reserve_id integer
function o.unreserve( reserve_id )
  o.reserved_items[ reserve_id ] = nil
end

--- Get the total of an item or a tag in the storage.
---@param resource Resource
---@return integer
function o.get_total( resource )
  local quantity = 0
  for _, inventory_name in ipairs( o.find_inventories() ) do
    local inventory = peripheral.wrap( inventory_name )
    for index, _ in pairs( inventory.list() ) do
      for resource_item in resource:iterator() do
        local item = inventory.getItemDetail( index )
        if ( item.name == resource_item.name ) or ( item.tags[ resource_item.tag ] ) then
          quantity = quantity + item.count
        end
      end
    end
  end
  -- Substract total of reserved resource of the same tag/name.
  for _, v in ipairs( o.get_total_reserved() ) do
    if v == resource then quantity = math.max( 0, quantity - v.quantity ) end
  end
  return quantity
end

--- Get the list of all the reserved resources.
---@return Resource[] total_reserved_resources
function o.get_total_reserved()
  local total_reserved_resources = {}
  -- Each group of reserved items.
  for _, reserved_group in pairs( o.reserved_items ) do
    -- Each item in the group.
    for _, reserved_item in ipairs( reserved_group ) do
      -- Each item in the total.
      local item_exist = false
      for _, v2 in ipairs( total_reserved_resources ) do
        if reserved_group == v2 then
          total_reserved_resources.quantity = total_reserved_resources.quantity + reserved_item.quantity
          item_exist = true
          break
        end
      end
      -- If it dosent exist, we copy the resource.
      if not item_exist then
        table.insert( total_reserved_resources, reserved_item:copy() )
      end
    end
  end
  return total_reserved_resources
end

--- Push a resource to the turtle in the back.
---@param resource Resource
---@param slot_index integer
---@return boolean # If items were pushed.
function o.transfer_item_to_crafting_turtle( resource, slot_index )
  local inventory, index = o.find_resource( resource )
  assert( inventory, "The inventory is nil!" )
  local first_item = resource:iterator()()
  CLogManager.log_info( "Transfered " .. resource.quantity .. " " .. ( first_item.tag or first_item.tag ) .. " to the crafting turtle." )
  local item_pushed = inventory.pushItems( "back", index, resource.quantity, slot_index )
  return item_pushed > 0
end

--- Remove crafted items from the crafting turtle.
function o.empty_crafting_turtle()
  local inventory = o.get_first_inventory()
  assert( inventory, "The inventory is nil!" )
  for i = 1, 16 do
    local item_pulled = inventory.pullItems( "back", i )
    if item_pulled == 0 then break end
  end
end

return o
