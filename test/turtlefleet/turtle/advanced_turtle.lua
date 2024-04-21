local TLogManager = require( "turtlefleet.managers.t_log_manager" )

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
  [ turtle.DOWN ] = "down",
  [ turtle.FORWARD ] = "forward"
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

-- Status of the turtle. (Used with the FleetManager)
t.status = "idle"

-- Task from the FleetManager.
t.task = nil

-- Equipment
t.equpment_left = nil
t.equpment_right = nil

-- Turtle position
t.x = 0
t.y = 0
t.z = 0

---The position as a vector.
---@return vector
function t.position() return vector.new( t.x, t.y, t.z ) end

-- -1: WEST, 1: EAST
t.dx = 0
 -- -1: NORTH, 1: SOUTH
t.dz = 0

-- Used to know if the turtle need to figure out it's facing direction.
t.position_acuracy = "bad"

--- Get the direction the turtle is facing.
---@return integer|nil # NORTH, WEST, EAST, SOUTH, nil
function t.facing()
  if t.dz == -1 and t.dx == 0 then return turtle.NORTH
  elseif t.dz == 0 and t.dx == -1 then return turtle.WEST
  elseif t.dz == 0 and t.dx == 1 then return turtle.EAST
  elseif t.dz == 1 and t.dx == 0 then return turtle.SOUTH
  end
  return nil
end


--------------
-- Settings --
--------------

--- Load the data from the settings file.
function t.load_settings()
  local pos = settings.get( "position" )
  t.x, t.y, t.z = pos.x, pos.y, pos.z
  local face = settings.get( "facing" )
  t.dx, t.dz = face.dx, face.dz
  if t.x == 0 and t.y == 0 and t.z == 0 or ( t.dx == 0 and t.dz == 0 ) then t.position_acuracy = "bad" else t.position_acuracy = "good" end
  t.equpment_left = settings.get( "equpment_left" )
  t.equpment_right = settings.get( "equpment_right" )
  t.slots = settings.get( "slots" )
end

--- Set the data that are still nil or invalid.
function t.set_missing()
  if t.equpment_left == nil then
    t.equpment_left = turtle.get_eqipment( turtle.LEFT )
    TSettingsManager.set( "equpment_left", t.equpment_left )
  end
  if t.equpment_right == nil then
    t.equpment_right = turtle.get_eqipment( turtle.RIGHT )
    TSettingsManager.set( "equpment_right", t.equpment_right )
  end
end

--- If the turtle has a storage type configured.
---@param storage_type integer
---@return boolean
function turtle.has_storage( storage_type )
  for _, v in pairs( turtle.storage ) do
    if v.type == storage_type then
      return true
    end
  end
  return false
end

--- If the turtle has a storage for fuel.
---@return unknown
function t.has_fuel_chest()
  return t.has_storage( turtle.FUEL_STORAGE )
end


-----------------
--- Movements ---
-----------------

-- Forward --
-- TODO: Check facing direction if position acuracy is "good".
--       The turtle might be at the same position but facing a different way.
function t.forward()
  t.try_refuel()
  if not t.old_forward() then return false end
  t.x = t.x + t.dx
  t.z = t.z + t.dz
  TSettingsManager.save_position()
  return true
end

-- Down --
function t.down()
  t.try_refuel()
  if not t.old_down() then return false end
  t.y = t.y - 1
  TSettingsManager.save_position()
  return true
end

-- Back --
function t.back()
  t.try_refuel()
  if not t.old_back() then return false end
  t.x = t.x - t.dx
  t.z = t.z - t.dz
  TSettingsManager.save_position()
  return true
end

-- Up --
function t.up()
  t.try_refuel()
  if not t.old_up() then return false end
  t.y = t.y + 1
  TSettingsManager.save_position()
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

-- Destroy block until it can move.
function t.force_move( direction )
  if direction == nil then error( "turtle.move(): direction is null. " .. debug.getinfo(2).name ) end
  while not t.move( direction ) do
    t.dig( direction )
    sleep( 0.1 )
  end
end

-- Wait until it can move.
function t.wait_move( direction )
  while not t.move( direction ) do
    sleep( 0.5 )
  end
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
  t.dx, t.dz = -t.dz, t.dx
  TSettingsManager.save_facing()
  return true
end

--- Simply turn left.
---@return boolean
function t.turnLeft()
  t.old_turnLeft()
  t.dx, t.dz = t.dz, -t.dx
  TSettingsManager.save_facing()
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


-----------
--- Dig ---
-----------

--- Dig in a specific direction.
---@param direction any
function t.dig( direction )
  if direction == t.UP then
    t.digUp()
  elseif direction == t.DOWN then
    t.digDown()
  elseif direction == t.FORWARD then
    t.old_dig()
  else
    t.turn( direction )
    t.old_dig()
  end
end

-- Mine until it can't mine again! (falling block safe)
function turtle.dig_all( direction )
  local has_dug = turtle.dig( direction )

  if not has_dug then
    return false
  end

  while has_dug do
    sleep( 0.05 )
    has_dug = turtle.dig( direction )
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
  elseif direction == t.FORWARD then
    return t.old_inspect()
  else
    t.turn( direction )
    return t.old_inspect()
  end
end

-- Check if the block has the tag.
function t.is_block_tag( dir, tag )
  local s, d = turtle.inspect( dir )

  -- If there is nothing, return.
  if not s then return false end

  -- If in minecraft 1.12, there is no "tags" table
  if type( d.tags ) == "table" then
    for k, _ in pairs( d.tags ) do
      if string.find( k, tag ) ~= nil then
        return true
      end
    end
  end

  -- Else, try to find it in the name.
  return string.find( d.name, tag ) ~= nil
end

--- Compare a block's name in a direction.
---@param direction any
---@param block_name string
---@return boolean
function t.is_block_name( direction, block_name )
  local s, d = t.inspect( direction )
  return s and d.name == block_name
end

-----------------
-- New Actions --
-----------------

-- If the turtle has a bucket, it will try to refuel with lava in the world.
function t.check_lava_source( direction )
  -- Dont lose time checking back.
  if direction == t.BACK then
    return
  end

  -- Only check if it has a bucket.
  local bucket_index = t.get_item_index( "minecraft:bucket" )
  if bucket_index ~= -1 then
    local s, d = t.inspect( direction )
    if s and d.name == "minecraft:lava" and d.state.level == 0 then
      t.select( bucket_index )
      t.placeDir( direction )
      t.refuel()
      t.select( 1 )
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

--- If all the slots are occupied by at least 1 item.
function t.is_inventory_full()
  for i = 1, 16 do if turtle.getItemCount( i ) == 0 then return false end end
  return true
end


----------
-- Fuel --
----------

-- Check if it needs to refuel.
function t.try_refuel()
  -- Do nothing if the turtle is set to unlimited fuel in the config.
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

------------
--- Jobs ---
------------

turtle = t
turtle = require( "turtlefleet.turtle.jobs.miner" )

return turtle