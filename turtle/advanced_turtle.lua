-----------------------------
-- global turtle functions --
-----------------------------
if not turtle then return end

turtle.forbidden_block = {}
turtle.valid_fuel = {}
turtle.storage = {}
turtle.refuel_all = false
turtle.is_dropping_in_storage = false

turtle.FUEL_STORAGE = 1
turtle.DROP_STORAGE = 2
turtle.FILTERED_DROP_STORAGE = 3

turtle.default_do_not_store_items = {
  [ "minecraft:bucket" ] = 1
}

turtle.do_not_store_items = turtle.default_do_not_store_items

turtle.storage_names = {
  [ turtle.FUEL_STORAGE ] = "Fuel storage",
  [ turtle.DROP_STORAGE ] = "Drop storage",
  [ turtle.FILTERED_DROP_STORAGE ] = "Filtered storage",
}

turtle.NORTH = 0
turtle.EAST = 1
turtle.SOUTH = 2
turtle.WEST = 3
turtle.LEFT = 4
turtle.RIGHT = 5

turtle.x = 0
turtle.y = 0
turtle.z = 0
turtle.dz = -1
turtle.dx = 0

if turtle.old_up == nil then
  turtle.old_turnRight = turtle.turnRight
  turtle.old_turnLeft = turtle.turnLeft
  turtle.old_forward = turtle.forward
  turtle.old_down = turtle.down
  turtle.old_back = turtle.back
  turtle.old_up = turtle.up
  turtle.old_place = turtle.place
  turtle.old_placeUp = turtle.placeUp
  turtle.old_placeDown = turtle.placeDown
end

function turtle.reverseDir( direction )
  if direction == "forward" then
    return "back"
  elseif direction == "down" then
    return "up"
  elseif direction == "back" then
    return "forward"
  elseif direction == "up" then
    return "down"
  end
  error( "turtle.reverseDir invalid direction!" )
end

function turtle.position() return vector.new( turtle.x, turtle.y, turtle.z ) end

function turtle.facing()
  if turtle.dz == -1 and turtle.dx == 0 then
    return turtle.NORTH
  elseif turtle.dz == 0 and turtle.dx == -1 then
    return turtle.WEST
  elseif turtle.dz == 0 and turtle.dx == 1 then
    return turtle.EAST
  elseif turtle.dz == 1 and turtle.dx == 0 then
    return turtle.SOUTH
  end
  error( "turtle.facing invalid direction!" )
end

--------------
-- settings -- 
--------------

-- Load all the settings
function turtle.load_settings()
  turtle.load_forbidden_block()
  turtle.load_valid_fuel()
  turtle.load_storage()
  turtle.load_refuel_all()
end

function turtle.load_forbidden_block()
  local loaded_block = settings.get( "forbidden_block" )

  if loaded_block then
    turtle.forbidden_block = loaded_block
  else
    turtle.set_forbidden_block( { "forbidden_arcanus:stella_arcanum" } )
  end
end

function turtle.load_valid_fuel()
  local loaded_fuel = settings.get( "valid_fuel" )

  if loaded_fuel then
    turtle.valid_fuel = loaded_fuel
  else
    turtle.set_valid_fuel( { "minecraft:charcoal", "minecraft:coal" } )
  end
end

function turtle.load_refuel_all()
  turtle.refuel_all = settings.get( "refuel_all" ) or false
end

-- Load the storage settings
function turtle.load_storage()
  local loaded_storage = settings.get( "storage" )

  if loaded_storage then
    turtle.storage = loaded_storage
  end
end

function turtle.set_forbidden_block( new_forbidden_block )
  turtle.forbidden_block = new_forbidden_block
  settings.set( "forbidden_block", turtle.forbidden_block )
  settings.save(".settings")
end

function turtle.set_valid_fuel( new_valid_fuel )
  turtle.valid_fuel = new_valid_fuel
  settings.set( "valid_fuel", turtle.valid_fuel )
  settings.save(".settings")
end

function turtle.set_storage( index, new_storage )
  turtle.storage[ index ] = new_storage
  settings.set( "storage", turtle.storage )
  settings.save(".settings")
end

function turtle.set_refuel_all( value )
  turtle.refuel_all = value
  settings.set( "refuel_all", value )
  settings.save(".settings")
end

function turtle.remove_storage_config( index )
  turtle.storage[ index ] = nil
  settings.set( "storage", turtle.storage )
  settings.save(".settings")
end

function turtle.add_or_remove_valid_fuel( item_name )
  local was_removed = false

  for k, v in pairs( turtle.valid_fuel ) do
    if v == item_name then
      table.remove( turtle.valid_fuel, k )
      was_removed = true
      break
    end
  end

  if not was_removed then
    table.insert( turtle.valid_fuel, item_name )
  end

  turtle.set_valid_fuel( turtle.valid_fuel )
end

function turtle.add_or_remove_forbidden_block( block_name )
  local was_removed = false

  for k, v in pairs( turtle.forbidden_block ) do
    if v == block_name then
      table.remove( turtle.forbidden_block, k )
      was_removed = true
      break
    end
  end

  if not was_removed then
    table.insert( turtle.forbidden_block, block_name )
  end

  turtle.set_forbidden_block( turtle.forbidden_block )
end

turtle.load_settings()

-----------------
--- Movements ---
-----------------

-- Forward --
function turtle.forward()
  turtle.try_refuel()
  if not turtle.old_forward() then return false end
  turtle.x = turtle.x + turtle.dx
  turtle.z = turtle.z + turtle.dz
  return true
end

function turtle.wait_forward()
  while not turtle.forward() do
    sleep( 0.5 )
  end
end

function turtle.force_forward( block_to_break )
  turtle.force_move( "forward", block_to_break )
end

-- Down --
function turtle.down()
  turtle.try_refuel()
  if not turtle.old_down() then return false end
  turtle.y = turtle.y - 1
  return true
end

function turtle.wait_down()
  while not turtle.down() do sleep( 0.5 )
  end
end

function turtle.force_down( block_to_break )
  turtle.force_move( "down", block_to_break )
end

-- Back --
function turtle.back()
  turtle.try_refuel()
  if not turtle.old_back() then return false end
  turtle.x = turtle.x - turtle.dx
  turtle.z = turtle.z - turtle.dz
  return true
end

function turtle.wait_back()
  while not turtle.back() do
    sleep( 0.5 )
  end
end

function turtle.force_back( block_to_break )
  turtle.force_move( "back", block_to_break )
end

-- Up --
function turtle.up()
  turtle.try_refuel()
  if not turtle.old_up() then return false end
  turtle.y = turtle.y + 1
  return true
end

function turtle.wait_up()
  while not turtle.up() do
    sleep( 0.5 )
  end
end

function turtle.force_up( block_to_break )
  turtle.force_move( "up", block_to_break )
end

-- Move Direction --
function turtle.moveDir( direction )
  if direction == "forward" then
    return turtle.forward()
  elseif direction == "down" then
    return turtle.down()
  elseif direction == "back" then
    return turtle.back()
  elseif direction == "up" then
    return turtle.up()
  end
  error( "turtle.moveDir direction unknown!" )
end

-- Reverse --
function turtle.reverse( direction )
  return turtle.moveDir( turtle.reverseDir( direction ) )
end

function turtle.force_reverse( direction )
  turtle.force_move( turtle.reverseDir( direction ) )
end

-- Move --
function turtle.wait_move( direction )
  while not turtle.move( direction ) do
    print( "waiting 5 seconds before trying to move", direction, "again." )
    sleep( 5 )
  end
end

function turtle.move( direction, block_to_break )
  turtle.check_lava_source( direction )
  turtle.try_refuel()

  local moved = turtle.moveDir( direction )
  if not moved and block_to_break and turtle.is_block_name( direction, block_to_break ) then
    turtle.digDir( direction )
    return turtle.moveDir( direction )
  end

  return moved
end

function turtle.force_move( direction, block_to_break )
  if direction ~= "back" then
    for k, v in pairs( turtle.forbidden_block ) do
      if turtle.is_block_name( direction, v ) then
        print( "I am scared of this", v, ". Can you remove it please?" )

        while turtle.is_block_name( direction, v ) do
          sleep( 5 )
        end
      end
    end

    turtle.check_lava_source( direction )
  end

  while not turtle.moveDir( direction ) do
    local s, d = turtle.inspectDir( direction )
    if s and string.find( d.name, "turtle" ) then
      sleep( 0.5 )
    elseif not block_to_break or turtle.is_block_name( direction, block_to_break ) then
      turtle.digDir( direction )
    end
  end
end

function turtle.force_move_path( path )
  for i = 1, #path do
    local dir = path:sub( i, i )

    if dir == "d" then
      turtle.force_move( "down" )
    elseif dir == "u" then
      turtle.force_move( "up" )
    elseif dir == "f" then
      turtle.force_move( "forward" )
    elseif dir == "b" then
      turtle.force_move( "back" )
    elseif dir == "l" then
      turtle.turnLeft()
    elseif dir == "r" then
      turtle.turnRight()
    elseif dir == "n" then
      turtle.turn( turtle.NORTH )
    elseif dir == "s" then
      turtle.turn( turtle.SOUTH )
    elseif dir == "e" then
      turtle.turn( turtle.EAST )
    elseif dir == "w" then
      turtle.turn( turtle.WEST )
    end
  end
end

---------------
--- Turning ---
---------------

function turtle.turnRight()
  turtle.old_turnRight()
  local old_dx = turtle.dx
  turtle.dx = -turtle.dz
  turtle.dz = old_dx
  return true
end

function turtle.turnLeft()
  turtle.old_turnLeft()
  local old_dx = turtle.dx
  turtle.dx = turtle.dz
  turtle.dz = -old_dx
  return true
end

function turtle.turn180()
  if math.random( 2 ) == 1 then
    turtle.turnLeft()
    turtle.turnLeft()
  else
    turtle.turnRight()
    turtle.turnRight()
  end
end

function turtle.turnDir( direction )
  if direction == turtle.LEFT then
    return turtle.turnLeft()
  elseif direction == turtle.RIGHT then
    return turtle.turnRight()
  end
  error( "turtle.turnDir invalid direction!" )
end

function turtle.turn( direction )
  local facing = turtle.facing()
  if facing == direction then return end

  if direction > 3 then
    turtle.turnDir( direction )
  else
    if math.abs( facing - direction ) == 2 then
      turtle.turn180()
    else
      if (facing - direction) % 4 == 1 then
        turtle.turnLeft()
      else
        turtle.turnRight()
      end
    end
  end
end


-----------
--- Dig ---
-----------

function turtle.digBack()
  turtle.turn180()
  turtle.dig()
  turtle.turn180()
end

-- Mine until it can't mine again! (falling block safe)
function turtle.dig_all( direction )
  local has_dug = turtle.digDir( direction )

  if not has_dug then
    return false
  end

  while has_dug do
    sleep( 0.05 )
    has_dug = turtle.digDir( direction )
  end

  return true
end

function turtle.digDir( direction )
  local succes, err

  if direction == "forward" then
    succes, err = turtle.dig()
  elseif direction == "up" then
    succes, err = turtle.digUp()
  elseif direction == "down" then
    succes, err = turtle.digDown()
  elseif direction == "back" then
    succes, err = turtle.digBack()
  else
    error( "turtle.digDir invalid direction" )
  end

  turtle.check_lava_source( direction )

  if turtle.is_inventory_full() then
    turtle.drop_in_storage()
  end

  return succes, err
end

-- Detect --
function turtle.detectBack()
  turtle.turn180()
  local success = turtle.detect()
  turtle.turn180()
  return success
end

function turtle.detectDir( direction )
  if direction == "forward" then
    return turtle.detect()
  elseif direction == "up" then
    return turtle.detectUp()
  elseif direction == "down" then
    return turtle.detectDown()
  elseif direction == "back" then
    return turtle.detectBack()
  end
  error( "turtle.detectDir invalid direction!" )
end

-- Inspect --
function turtle.inspectBack()
  turtle.turn180()
  local success, data = turtle.inspect()
  turtle.turn180()
  return success, data
end

function turtle.inspectLeft()
  turtle.turnLeft()
  local success, data = turtle.inspect()
  turtle.turnRight()
  return success, data
end

function turtle.inspectRight()
  turtle.turnRight()
  local success, data = turtle.inspect()
  turtle.turnLeft()
  return success, data
end

function turtle.inspectDir( direction )
  if direction == "up" then
    return turtle.inspectUp()
  elseif direction == "down" then
    return turtle.inspectDown()
  elseif direction == "forward" then
    return turtle.inspect()
  elseif direction == "back" then
    return turtle.inspectBack()
  elseif direction == "left" then
    return turtle.inspectLeft()
  elseif direction == "right" then
    return turtle.inspectRight()
  end
  error( "inspectDir direction unknown!" )
end

function turtle.is_block_name( direction, block_name )
  local s, d = turtle.inspectDir( direction )
  return s and d.name == block_name
end

function turtle.is_block_name_contains( direction, block_name )
  local s, d = turtle.inspectDir( direction )
  return s and string.find( d.name, block_name )
end

-- Check if the block has the tag.
function turtle.is_block_tag( dir, tag )
  local s, d = turtle.inspectDir( dir )

  -- If there is nothing, return.
  if not s then return false end

  -- If in minecraft 1.12, there is no "tags" table
  if type( d.tags ) == "table" then
    for k, v in pairs( d.tags ) do
      if string.find( k, tag ) ~= nil then
        return true
      end
    end
  end
  
  -- Else, try to find it in the name.
  return string.find( d.name, tag ) ~= nil
end

-------------
--- Place ---
-------------

-- place a block in front.
function turtle.place( item_index )
  if item_index then turtle.select( item_index ) end
  return turtle.old_place()
end

-- place a block above.
function turtle.placeUp( item_index )
  if item_index then turtle.select( item_index ) end
  return turtle.old_placeUp()
end

-- place a block below.
function turtle.placeDown( item_index )
  if item_index then turtle.select( item_index ) end
  return turtle.old_placeDown()
end

-- Place a block to its right.
function turtle.placeRight( item_index )
  turtle.turnRight()
  local placed = turtle.place( item_index )
  turtle.turnLeft()
  return placed
end

-- Place a block to its left.
function turtle.placeLeft( item_index )
  turtle.turnLeft()
  local placed = turtle.place( item_index )
  turtle.turnRight()
  return placed
end

-- place a block based on a direction.
function turtle.placeDir( direction )
  if direction == "forward" then
    return turtle.place()
  elseif direction == "up" then
    return turtle.placeUp()
  elseif direction == "down" then
    return turtle.placeDown()
  elseif direction == "left" then
    return turtle.placeLeft()
  elseif direction == "right" then
    return turtle.placeRight()
  end
  error( "turtle.placeDir invalid direction" )
end

function turtle.wait_place( direction )
  while not turtle.placeDir( direction ) do
    print( "waiting 5 seconds before trying to place", direction, "again." )
    sleep( 5 )
  end
end

-- Suck --
function turtle.suckDir( direction )
  if direction == "forward" then
    return turtle.suck()
  elseif direction == "up" then
    return turtle.suckUp()
  elseif direction == "down" then
    return turtle.suckDown()
  end
  error( "turtle.suckDir invalid direction" )
end

function turtle.wait_suck( direction ) while not turtle.suckDir( direction ) do sleep( 1 ) end end

-- Return succes and if false, the name of the block
function turtle.move_inspect( direction )
  if turtle.moveDir( direction ) then return true, nil end

  local s, d = turtle.inspectDir( direction )
  return false, d.name
end

function turtle.move_toward( destination )
  local distance = destination - turtle.position()

  if distance.x ~= 0 then
    if distance.x > 0 then
      turtle.turn( turtle.EAST )
    else
      turtle.turn( turtle.WEST )
    end
    return turtle.move_inspect( "forward" )
  end

  if distance.z ~= 0 then
    if distance.z > 0 then
      turtle.turn( turtle.SOUTH )
    else
      turtle.turn( turtle.NORTH )
    end
    return turtle.move_inspect( "forward" )
  end

  if distance.y ~= 0 then
    if distance.y > 0 then
      return turtle.move_inspect( "up" )
    else
      return turtle.move_inspect( "down" )
    end
  end

  return true
end

function turtle.dig_toward( destination )
  local distance = destination - turtle.position()

  if distance.x ~= 0 then
    if distance.x > 0 then
      turtle.turn( turtle.EAST )
    else
      turtle.turn( turtle.WEST )
    end
    return turtle.force_move( "forward" )
  end

  if distance.z ~= 0 then
    if distance.z > 0 then
      turtle.turn( turtle.SOUTH )
    else
      turtle.turn( turtle.NORTH )
    end
    return turtle.force_move( "forward" )
  end

  if distance.y ~= 0 then
    if distance.y > 0 then
      return turtle.force_move( "up" )
    else
      return turtle.force_move( "down" )
    end
  end

  return true
end

-- array of vector
function turtle.follow_path( path, can_dig )
  for i = 1, #path do
    if (can_dig) then
      turtle.dig_toward( path[i] )
    else
      local s, n = turtle.move_toward( path[i] )

      if not s then
        map_add( path[i], n )
        save_map()
        return false
      end
    end
  end

  return true
end

function turtle.pathfind_to( destination, can_dig )
  print( "Going to: " .. tostring( destination ) )
  local path = turtle.A_Star( turtle.position(), destination )

  while not turtle.follow_path( path, can_dig ) do
    print( "recalculating a path." )
    path = turtle.A_Star( turtle.position(), destination )
  end

  print( "ARRIVED !" )
end

-- Inventory --
function turtle.getInventory()
  local inv = {}
  for i = 1, 16 do inv[i] = turtle.getItemDetail( i ) end
  return inv
end

function turtle.get_empty_slot_index()
  for i = 1, 16 do
    if turtle.getItemCount( i ) == 0 then
      return i
    end
  end
  return -1
end

-- Select a slot, if there is an item, move it to another slot witch is not a storage.
function turtle.empty_select( index )
  turtle.select( index )

  if turtle.getItemCount() > 0 then
    for i = 1, 16 do
      if i ~= index and not turtle.is_storage_slot( i ) and turtle.getItemCount( i ) == 0 then
        turtle.transferTo( i )
        return
      end
    end
  end
end

function turtle.get_item_index( name )
  for i = 1, 16 do
    local item = turtle.getItemDetail( i )
    if item and string.find( item.name, name ) then
      return i
    end
  end
  return -1
end

function turtle.has_items()
  for i = 1, 16 do if turtle.getItemCount( i ) > 0 then return true end end
  return false
end

-- If all the slots are occupied.
function turtle.is_inventory_full()
  for i = 1, 16 do if turtle.getItemCount( i ) == 0 then return false end end
  return true
end

-- Return if the inventory is filled more than the percentage.
function turtle.is_inventory_filled_more_than( percent_limit )
  local occupied_slot = 0
  for i = 1, 16 do
    if turtle.getItemCount( i ) > 0 then
      occupied_slot = occupied_slot + 1
    end
  end

  local current_percent = occupied_slot / 16
  return current_percent > percent_limit
end

function turtle.get_info_paper_index()
  for i = 1, 16 do
    local item = turtle.getItemDetail( i, true )
    if item and item.name == "minecraft:paper" and item.displayName ~= "Paper" then
      print( "info paper found" )
      return i
    end
  end
  return -1
end

function turtle.has_storage( storage_type )
  for k, v in pairs( turtle.storage ) do
    if v.type == storage_type then
      return true
    end
  end
  return false
end

function turtle.is_storage_slot( i )
  for k, v in pairs( turtle.storage ) do
    if k == i then
      return true
    end
  end
  return false
end

function turtle.get_storage_type( i )
  for k, v in pairs( turtle.storage ) do
    if k == i then
      return v.type
    end
  end
  return nil
end

function turtle.has_fuel_chest()
  return turtle.has_storage( turtle.FUEL_STORAGE )
end

function turtle.has_drop_chest()
  return turtle.has_storage( turtle.DROP_STORAGE )
end

function turtle.get_storage_index( storage_type )
  for k, v in pairs( turtle.storage ) do
    if v.type == storage_type then
      return k
    end
  end
  return -1
end

-- Drop the items in the configured storage.
function turtle.drop_in_storage()
  if turtle.is_dropping_in_storage then return end
  if not turtle.has_drop_chest() then return false end
  
  print( "Dropping in storage!" )
  
  turtle.is_dropping_in_storage = true
  local is_empty = false
  local to_keep = {}
  for k, v in pairs( turtle.do_not_store_items ) do
    to_keep[ k ] = v
  end

  -- prepare a list of item to drop
  -- index of the item -> indexes of the storages ( multiple if other are full ) single if filtered storage
  local to_drop = {}
  for i = 1, 16 do
    local item = turtle.getItemDetail( i )

    if item and turtle.can_be_stored( i ) then
      -- if need to keep the item
      if to_keep[ item.name ] and to_keep[ item.name ] > 0 then
        to_keep[ item.name ] = to_keep[ item.name ] - 1
      else
        to_drop[ i ] = turtle.get_storage_index_for_item( i )
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
      for k, v in pairs( to_drop ) do
        current_drop_index = v[ 1 ]
        break
      end

      turtle.select( current_drop_index )
      turtle.dig_all( "up" )

      while not turtle.placeUp() do
        sleep( 0.5 )
      end
      sleep( 0.5 )
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
            current_drop_index = turtle.get_next_storage_index( current_drop_index, storages_index )

            if current_drop_index == -1 then
              print( "Please, make some place in my storage then press enter?" )
                read()
                current_drop_index = storages_index[ 1 ]
              end

              turtle.select( current_drop_index )
              while not turtle.placeUp() do
                sleep( 0.5 )
              end

              sleep( 0.5 )
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
  turtle.is_dropping_in_storage = false
end

-- Gets if the item can be stored away.
function turtle.can_be_stored( index )
  if not turtle.is_storage_slot( index ) then
    local item = turtle.getItemDetail( index )

    if not turtle.is_valid_fuel( item.name ) then
      return true
    end
  end
  return false
end

-- Find the index for the storage of the item at the given slot index.
-- single index for filtered storage, can be multiple for drop storage.
function turtle.get_storage_index_for_item( i )
  -- if we have a filtered storage configured, check if the item is in the filter.
  if turtle.has_storage( turtle.FILTERED_DROP_STORAGE ) then
    local item_data = turtle.getItemDetail( i )

    -- for each filtered storage
    for storage_index, storage_data in pairs( turtle.storage ) do
      if storage_data.type == turtle.FILTERED_DROP_STORAGE then
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
  for storage_index, storage_data in pairs( turtle.storage ) do
    if storage_data.type == turtle.DROP_STORAGE then
      table.insert( drop_storages_index, storage_index )
    end
  end
  return drop_storages_index
end

-- Gets the next storage index from the current one in the list.
function turtle.get_next_storage_index( current_drop_index, storages_index )
  for k, v in pairs( storages_index ) do
    if v == current_drop_index and storages_index[ k + 1 ] then
      return storages_index[ k + 1 ]
    end
  end
  return -1
end

----------
-- Fuel --
----------
function turtle.get_valid_fuel_index()
  for i = 1, 16 do
    local item = turtle.getItemDetail( i )

    for f = 1, #turtle.valid_fuel do
      if item and string.find( item.name, turtle.valid_fuel[f] ) then return i end
    end
  end

  return -1
end

function turtle.is_valid_fuel( item_name )
  for f = 1, #turtle.valid_fuel do
    if item_name == turtle.valid_fuel[f] then
      return true
    end
  end

  return false
end

function turtle.try_refuel()
  -- Do nothing if the turtle are set to not consume fuel in the mod config.
  if turtle.getFuelLimit() == "unlimited" then
    return
  end

  if turtle.getFuelLevel() < 80 then
    local fuel_index = turtle.get_valid_fuel_index()

    if fuel_index == -1 and turtle.has_fuel_chest() then
      turtle.get_fuel_from_storage()
      fuel_index = turtle.get_valid_fuel_index()
    end

    if fuel_index == -1 then
      print( "Give me fuel please!" )
      print( "Valid fluel:" )

      for f = 1, #turtle.valid_fuel do
        print( " - " .. turtle.valid_fuel[ f ] )
      end

      while fuel_index == -1 do
        sleep( 1 )
        fuel_index = turtle.get_valid_fuel_index()
      end
    end

    print( "Eating Some Fuel." )
    turtle.select( fuel_index )

    if turtle.refuel_all then
      turtle.refuel()
    else
      turtle.refuel( 2 )
    end
  end
end

function turtle.refuel_all()
  -- while not full and there is fuel in inventory.
  local has_fuel = true

  while turtle.getFuelLevel() < turtle.getFuelLimit() and has_fuel do
    local fuel_index = turtle.get_valid_fuel_index()

    if fuel_index == -1 and turtle.has_fuel_chest() then
      turtle.get_fuel_from_storage()
      fuel_index = turtle.get_valid_fuel_index()
    end

    if fuel_index == -1 then
      return
    end

    turtle.select( fuel_index )
    turtle.refuel()
  end
end

function turtle.get_fuel_from_storage()
  -- If there is no fuel sorage setup, return
  if not turtle.has_fuel_chest() then return false end

  -- if there is no free space, drop in storage
  if turtle.is_inventory_full() then turtle.drop_in_storage() end

  local fuel_storage_index = turtle.get_storage_index( turtle.FUEL_STORAGE )
  turtle.select( fuel_storage_index )
  local dir_to_place = turtle.get_empty_block()
  if dir_to_place == "" then
    dir_to_place = "up"
    turtle.dig_all( "up" )
  end

  while not turtle.placeDir( dir_to_place ) do sleep( 0.1 ) end
  turtle.select( ( fuel_storage_index  + 1 ) % 16 )
  turtle.wait_suck( dir_to_place )
  turtle.select( fuel_storage_index )
  turtle.digDir( dir_to_place )
  return true
end

function turtle.get_empty_block()
  if not turtle.detectUp() then return "up" end
  if not turtle.detectDown() then return "down" end
  return ""
end

--------------
-- Redstone --
--------------
function turtle.wait_for_signal( direction, strength )
  local valid_signal = false

  while not valid_signal do
    os.pullEvent( "redstone" )
    valid_signal = rs.getAnalogueInput( direction ) == strength
  end
end

function turtle.wait_for_any_rs_signal( direction )
  while true do
    os.pullEvent( "redstone" )

    local redstone_strength = rs.getAnalogueInput( direction )
    if redstone_strength > 0 then
      return redstone_strength
    end
  end
end

-----------
-- Extra --
-----------
function turtle.check_lava_source( direction )
  -- Dont lose time checking if it's back.
  if direction == "back" then
    return
  end

  -- Only check if it has a bucket.
  local bucket_index = turtle.get_item_index( "minecraft:bucket" ) 
  if bucket_index ~= -1 then
    local s, d = turtle.inspectDir( direction )
    if s and d.name == "minecraft:lava" and d.state.level == 0 then
      turtle.select( bucket_index )
      turtle.placeDir( direction )
      turtle.refuel()
      turtle.select( 1 )
    end
  end
end

function turtle.has_tags( name )

end