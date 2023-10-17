local t = turtle

-- Inventory --
function t.getInventory()
  local inv = {}
  for i = 1, 16 do inv[i] = turtle.getItemDetail( i ) end
  return inv
end

-- Select a slot, if there is an item, move it to another slot witch is not a storage.
function t.empty_select( index )
  turtle.select( index )

  if turtle.getItemCount() > 0 then
    for i = 1, 16 do
      if i ~= index and not t.is_storage_slot( i ) and turtle.getItemCount( i ) == 0 then
        turtle.transferTo( i )
        return
      end
    end
  end
end

function t.has_items()
  for i = 1, 16 do if turtle.getItemCount( i ) > 0 then return true end end
  return false
end

-- If all the slots are occupied.
function t.is_inventory_full()
  for i = 1, 16 do if turtle.getItemCount( i ) == 0 then return false end end
  return true
end

-- Return if the inventory is filled more than the percentage.
function t.is_inventory_filled_more_than( percent_limit )
  local occupied_slot = 0
  for i = 1, 16 do
    if turtle.getItemCount( i ) > 0 then
      occupied_slot = occupied_slot + 1
    end
  end

  local current_percent = occupied_slot / 16
  return current_percent > percent_limit
end

-- Find a paper in the inventory.
function t.get_info_paper_index()
  for i = 1, 16 do
    local item = turtle.getItemDetail( i, true )
    if item and item.name == "minecraft:paper" and item.displayName ~= "Paper" then
      print( "info paper found." )
      return i
    end
  end
  return -1
end

function t.has_storage( storage_type )
  for k, v in pairs( turtle.storage ) do
    if v.type == storage_type then
      return true
    end
  end
  return false
end

function t.is_storage_slot( i )
  for k, v in pairs( t.storage ) do
    if k == i then
      return true
    end
  end
  return false
end

function t.get_storage_type( i )
  for k, v in pairs( t.storage ) do
    if k == i then
      return v.type
    end
  end
  return nil
end

function t.has_fuel_chest()
  return t.has_storage( t.FUEL_STORAGE )
end

function t.has_drop_chest()
  return t.has_storage( t.DROP_STORAGE )
end

function t.get_storage_index( storage_type )
  for k, v in pairs( t.storage ) do
    if v.type == storage_type then
      return k
    end
  end
  return -1
end

-- Drop the items in the configured storage.
function t.drop_in_storage()
  if t.is_dropping_in_storage then return end
  if not t.has_drop_chest() then return false end

  print( "Dropping in storage!" )

  t.is_dropping_in_storage = true
  local to_keep = {}
  for k, v in pairs( t.do_not_store_items ) do
    to_keep[ k ] = v
  end

  -- prepare a list of item to drop
  -- index of the item -> indexes of the storages ( multiple if other are full ) single if filtered storage
  local to_drop = {}
  for i = 1, 16 do
    local item = turtle.getItemDetail( i )

    if item and t.can_be_stored( i ) then
      -- if need to keep the item
      if to_keep[ item.name ] and to_keep[ item.name ] > 0 then
        to_keep[ item.name ] = to_keep[ item.name ] - 1
      else
        to_drop[ i ] = t.get_storage_index_for_item( i )
      end
    end
  end

  local current_drop_index = -1

  -- length of table
  local to_drop_count = 0
  for _ in pairs( to_drop ) do to_drop_count = to_drop_count + 1 end

  -- While there is still items to drop
  while to_drop_count > 0 do
    -- if there is no drop storage out, take the first one
    if current_drop_index == -1 then
      for _, v in pairs( to_drop ) do
        current_drop_index = v[ 1 ]
        break
      end

      turtle.select( current_drop_index )
      t.dig_all( "up" )

      while not turtle.placeUp() do
        os.sleep( 0.5 )
      end
      os.sleep( 0.5 )
    end

    -- for each item to drop, drop them if they have that index
    -- if the storage is full, get the next one
    for item_index, storages_index in pairs( to_drop ) do
      for k, v in pairs( storages_index ) do
        -- If this item has can go in this storage, drop it
        if v == current_drop_index then
          turtle.select( item_index )
          local was_dropped, err = turtle.dropUp()
          while not was_dropped and err == "No space for items" do
            turtle.select( current_drop_index )
            turtle.digUp()

            -- get next storage index
            current_drop_index = t.get_next_storage_index( current_drop_index, storages_index )

            if current_drop_index == -1 then
              print( "Please, make some place in my storage then press enter?" )
                read()
                current_drop_index = storages_index[ 1 ]
              end

              turtle.select( current_drop_index )
              while not turtle.placeUp() do
                os.sleep( 0.5 )
              end

              os.sleep( 0.5 )
              turtle.select( item_index )
              was_dropped, err = turtle.dropUp()
            end

            -- Remove this item from the list
            to_drop[ item_index ] = nil
            to_drop_count = to_drop_count - 1
        end
      end
    end

    -- Pick up the storage
    turtle.select( current_drop_index )
    turtle.digUp()
    current_drop_index = -1
  end

  print( "Done dropping!" )
  t.is_dropping_in_storage = false
end

-- Gets if the item can be stored away.
function t.can_be_stored( index )
  if not t.is_storage_slot( index ) then
    local item = turtle.getItemDetail( index )

    if not turtle.is_valid_fuel( item.name ) then
      return true
    end
  end
  return false
end

-- Find the index for the storage of the item at the given slot index.
-- single index for filtered storage, can be multiple for drop storage.
function t.get_storage_index_for_item( i )
  -- if we have a filtered storage configured, check if the item is in the filter.
  if t.has_storage( t.FILTERED_DROP_STORAGE ) then
    local item_data = turtle.getItemDetail( i )

    -- for each filtered storage
    for storage_index, storage_data in pairs( t.storage ) do
      if storage_data.type == t.FILTERED_DROP_STORAGE then
        -- if the item is contained in the filter, return the index
        for k, filtered_item_name in pairs( storage_data.filtered_items ) do
          if item_data.name == filtered_item_name then
            return { storage_index }
          end
        end
      end
    end
  end

  -- get the indexes of normal drop storages.
  local drop_storages_index = {}
  for storage_index, storage_data in pairs( t.storage ) do
    if storage_data.type == t.DROP_STORAGE then
      table.insert( drop_storages_index, storage_index )
    end
  end
  return drop_storages_index
end

-- Gets the next storage index from the current one in the list.
function t.get_next_storage_index( current_drop_index, storages_index )
  for k, v in pairs( storages_index ) do
    if v == current_drop_index and storages_index[ k + 1 ] then
      return storages_index[ k + 1 ]
    end
  end
  return -1
end

-- Check if the item can be consumed to refuel.
function t.is_valid_fuel( item_name )
  for f = 1, #t.valid_fuel do
    if item_name == t.valid_fuel[ f ] then
      return true
    end
  end

  return false
end

-- Check if it needs to refuel.
function t.try_refuel()
  -- Do nothing if the turtle are set to not consume fuel in the mod config.
  if turtle.getFuelLimit() == "unlimited" then return end

  if turtle.getFuelLevel() < 80 then
    local fuel_index = t.get_valid_fuel_index()

    if fuel_index == -1 and t.has_fuel_chest() then
      t.get_fuel_from_storage()
      fuel_index = t.get_valid_fuel_index()
    end

    if fuel_index == -1 then
      print( "Give me fuel please!" )
      print( "Valid fluel:" )

      for f = 1, #t.valid_fuel do
        print( " - " .. t.valid_fuel[ f ] )
      end

      while fuel_index == -1 do
        os.sleep( 1 )
        fuel_index = t.get_valid_fuel_index()
      end
    end

    print( "Eating Some Fuel." )
    turtle.select( fuel_index )

    if t.refuel_all then
      turtle.refuel()
    else
      turtle.refuel( 2 )
    end
  end
end

-- Try to Get fuel from it's configured fuel storage.
function t.get_fuel_from_storage()
  -- If there is no fuel sorage setup, return
  if not t.has_fuel_chest() then return false end

  -- if there is no free space, drop in storage
  if t.is_inventory_full() then t.drop_in_storage() end

  local fuel_storage_index = t.get_storage_index( t.FUEL_STORAGE )
  turtle.select( fuel_storage_index )
  local dir_to_place = t.get_empty_block()
  if dir_to_place == "" then
    dir_to_place = "up"
    t.dig_all( "up" )
  end

  while not t.placeDir( dir_to_place ) do os.sleep( 0.1 ) end
  turtle.select( ( fuel_storage_index  + 1 ) % 16 )
  t.wait_suck( dir_to_place )
  turtle.select( fuel_storage_index )
  t.digDir( dir_to_place )
  return true
end

-- Check if up or down is air.
function t.get_empty_block()
  if not turtle.detectUp() then return "up" end
  if not turtle.detectDown() then return "down" end
  return ""
end

--------------
-- Redstone --
--------------

-- Wait for a specific redstone signal from a direction.
function t.wait_for_signal( direction, strength )
  local valid_signal = false

  while not valid_signal do
    os.pullEvent( "redstone" )
    valid_signal = rs.getAnalogueInput( direction ) == strength
  end
end

-- Wait for any redstone signal from a direction.
function t.wait_for_any_rs_signal( direction )
  while true do
    os.pullEvent( "redstone" )

    local redstone_strength = rs.getAnalogueInput( direction )
    if redstone_strength > 0 then
      return redstone_strength
    end
  end
end

return t