--------------------------
-- Turtle's old methods --
--------------------------

-- Save the basic turtle functions.
if turtle.old_up == nil then
  turtle.old_up = turtle.up
  turtle.old_dig = turtle.dig
  turtle.old_back = turtle.back
  turtle.old_down = turtle.down
  turtle.old_place = turtle.place
  turtle.old_detect = turtle.detect
  turtle.old_inspect = turtle.inspect
  turtle.old_placeUp = turtle.placeUp
  turtle.old_forward = turtle.forward
  turtle.old_turnLeft = turtle.turnLeft
  turtle.old_turnRight = turtle.turnRight
  turtle.old_placeDown = turtle.placeDown
end

--------------------------
-- Turtle's Enums --
--------------------------

-- Enum: Directions.
turtle.NORTH = 0
turtle.EAST = 1
turtle.SOUTH = 2
turtle.WEST = 3
turtle.LEFT = 4
turtle.RIGHT = 5
turtle.UP = 6
turtle.DOWN = 7
turtle.BACK = 8
turtle.FORWARD = 9

-- Direction names.
turtle.direction_names = {
  [ turtle.NORTH ] = "north",
  [ turtle.EAST ] = "east",
  [ turtle.SOUTH ] = "south",
  [ turtle.WEST ] = "west",
  [ turtle.LEFT ] = "left",
  [ turtle.RIGHT ] = "right",
  [ turtle.UP ] = "up",
  [ turtle.DOWN ] = "down"
}

-- Enum: Type of storages.
turtle.FUEL_STORAGE = 1
turtle.DROP_STORAGE = 2
turtle.FILTERED_DROP_STORAGE = 3

-- Names of the storages type.
turtle.storage_names = {
  [ turtle.FUEL_STORAGE ] = "Fuel storage",
  [ turtle.DROP_STORAGE ] = "Drop storage",
  [ turtle.FILTERED_DROP_STORAGE ] = "Filtered storage",
}

-- Get the oposite direction.
turtle.reverse = {
  [ turtle.UP ] = turtle.DOWN,
  [ turtle.DOWN ] = turtle.UP,
  [ turtle.BACK ] = turtle.FORWARD,
  [ turtle.FORWARD ] = turtle.BACK
}

----------------------------
-- Turtle's new variables --
----------------------------

local t = turtle

-- The block that are forbidden to break.
t.forbidden_block = {}

-- The items that can be consumed to refuel the turtle.
t.valid_fuel = {}

-- The configured storages carried by the turtle.
t.storage = {}

-- If the turtle should consume the whole stack of fuel.
t.refuel_all = false

-- If the turtle is currently dropping stuff in it's storages.
t.is_dropping_in_storage = false

-- Current List of items that should not be stored.
t.do_not_store_items = {}

--- If the turtle received a valid position from the gps.
t.has_valid_position = false

--- Turtle data object.
t.data = nil

-----------------
--- Movements ---
-----------------

-- Forward --
-- TODO: Check facing direction if position acuracy is "good".
--       The turtle might be at the same position but facing a different way.
function t.forward()
  t.try_refuel()
  if not t.old_forward() then return false end
  t.data:forward()
  return true
end

-- Down --
function t.down()
  t.try_refuel()
  if not t.old_down() then return false end
  t.data:down()
  return true
end

-- Back --
function t.back()
  t.try_refuel()
  if not t.old_back() then return false end
  t.data:back()
  return true
end

-- Up --
function t.up()
  t.try_refuel()
  if not t.old_up() then return false end
  t.data:up()
  return true
end

-- General Move --
function t.move( direction, block_to_break )
  if direction == nil then error( "turtle.move(): direction is null. " .. debug.getinfo(2).name ) end
  TLogManager.log_trace( "Moving " .. t.direction_names[ direction ] .. "." )
  t.check_lava_source( direction )
  t.try_refuel()

  local moved = false
  if direction == turtle.FORWARD then moved = t.forward()
  elseif direction == turtle.DOWN then moved = t.down()
  elseif direction == turtle.BACK then moved = t.back()
  elseif direction == turtle.UP then moved = t.up()
  else
    turtle.turn( direction )
    moved = t.forward()
  end

  if not moved and block_to_break and t.is_block_name( direction, block_to_break ) then
    t.dig( direction )
    return t.move( direction )
  end

  return moved
end

-- Follows a path of vector.
function turtle.move_path( path )
  if path == nil then print( "turtle.move_path( path ): Path is nil! " .. debug.getinfo(2).name ) end
  for _, pos in ipairs( path ) do
    local position = turtle.data:position()
    local vector_direction = pos - position
    if vector_direction.x == 0 and vector_direction.y == 0 and vector_direction.z == 0 then error( "turtle.move_path( path ): Cant move on same position." ) end
    local direction = Utils.get_direction( vector_direction )

    while not turtle.move( direction ) do
      TLogManager.log_error( "Path is blocked to the " .. turtle.direction_names[ direction ] .. "" )
      sleep( 2 )
    end
  end

  return true
end


---------------
--- Turning ---
---------------

--- Simply turn right.
---@return boolean
function t.turnRight()
  t.old_turnRight()
  t.data:turnRight()
  return true
end

--- Simply turn left.
---@return boolean
function t.turnLeft()
  t.old_turnLeft()
  t.data:turnRight()
  return true
end

--- Turn 180 randomly left or right.
function t.turn180()
  if math.random( 2 ) == 1 then
    t.turnLeft(); t.turnLeft()
  else
    t.turnRight(); t.turnRight()
  end
end

--- Turn the turtle to face a direction. Ex: turtle.NORTH
---@param direction integer NORTH, SOUTH, EAST, WEST, LEFT, RIGHT
---@return boolean
function t.turn( direction )
  local facing = t.data:facing()
  if facing == direction then return true end
  TLogManager.log_trace( "Turning from " .. t.direction_names[ facing ] .. " to " .. t.direction_names[ direction ] .. "." )
  -- If it's a cardinal direction.
  if direction <= turtle.WEST then
    if math.abs( facing - direction ) == 2 then
      t.turn180()
    else
      if ( facing - direction ) % 4 == 1 then
        t.turnLeft()
      else
        t.turnRight()
      end
    end
  else
    -- If its left or right
    if direction == t.LEFT then return t.turnLeft()
    elseif direction == t.RIGHT then return t.turnRight()
    -- Else, ignoring it.
    else return false end
  end
  return true
end


-------------
-- Inspect --
-------------

-- Inspect the block in the direction.
function t.inspect( direction )
  if direction == t.UP then return t.inspectUp()
  elseif direction == t.DOWN then return t.inspectDown()
  else
    t.turn( direction )
    return t.old_inspect()
  end
end


-----------------
-- New Actions --
-----------------

-- If the turtle has a bucket, it will try to refuel with lava in the world.
function turtle.check_lava_source( direction )
  -- Dont lose time checking back.
  if direction == turtle.BACK then
    return
  end

  -- Only check if it has a bucket.
  local bucket_index = turtle.get_item_index( "minecraft:bucket" )
  if bucket_index ~= -1 then
    local s, d = turtle.inspect( direction )
    if s and d.name == "minecraft:lava" and d.state.level == 0 then
      turtle.select( bucket_index )
      turtle.placeDir( direction )
      turtle.refuel()
      turtle.select( 1 )
    end
  end
end

---------------
-- Inventory --
---------------

--- Get the content of the inventory.
---@return table<integer, { item: string|nil, quantity: integer}> slots
function t.get_slots()
  local slots = {}
  for i = 1, 16 do
    local b = turtle.getItemDetail( i )
    if b then
      slots[ i ] = { item = b.name, quantity = b.count }
    else
      slots[ i ] = { item = nil, quantity = 0 }
    end
  end
  return slots
end

--- Find the first slot index for an item.
---@param name string The name of the item to search.
---@return integer slot_index The index where we found the item or -1 if we can't find it.
function t.get_item_index( name )
  for i = 1, 16 do
    local item = turtle.getItemDetail( i )
    if item and string.find( item.name, name ) then
      return i
    end
  end
  return -1
end

--- Get the index of the first empty slot.
---@return integer|nil slot_index
function t.get_empty_slot_index()
  for i = 1, 16 do
    if turtle.getItemCount( i ) == 0 then
      return i
    end
  end
  return nil
end

--- Equip or unequip an item to the given side.
---@param side integer LEFT or RIGHT
function t.equip( side )
  if side == t.LEFT then t.equipLeft() else t.equipRight() end
end

---Get the currently equipped item on a given side.
---@param side integer LEFT or RIGHT
---@return string|nil # Name of the equiped item.
function t.get_eqipment( side )
  local empty_index = t.get_empty_slot_index()
  if not empty_index then
    error( "get_eqipment(): TODO, error handling when inventory is full." )
  end
  t.select( empty_index )
  t.equip( side )
  local item = t.getItemDetail()
  t.equip( side )
  if item then return item.name end
  return "none"
end

--- Get on witch side an item is equiped.
---@param item_name string
---@return string|nil
function t.get_equipement_side( item_name )
  if t.data.equpment_left == item_name then return "left" end
  if t.data.equpment_right == item_name then return "right" end
  return nil
end

----------
-- Fuel --
----------

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
        sleep( 1 )
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

-- Get the index of the first valid fuel item in the inventory.
function t.get_valid_fuel_index()
  for i = 1, 16 do
    local item = turtle.getItemDetail( i )
    for f = 1, #t.valid_fuel do
      if item and string.find( item.name, t.valid_fuel[ f ] ) then return i end
    end
  end

  return -1
end


return t