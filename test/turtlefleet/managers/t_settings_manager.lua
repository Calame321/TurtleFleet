local o = {}

local FILE_NAME = ".settings"

-- Initialize the settings values.
function o.init()
  term.setCursorPos( 5, 5 )
  term.write( "Initializing settings..." )
  -- Define the settings with their default value.
  settings.define( "protocol", { description = "The protocol used to communicate with the turtles.", default = "fleet_protocol", type = "string" } )
  settings.define( "host_name", { description = "The name of computer that coordinates the turtles.", default = "command_center", type = "string" } )
  settings.define( "host_id", { description = "The id of the host.", default = -1, type = "number" } )
  settings.define( "task", { description = "The current task of the turtle.", default = nil, type = "table" } )
  settings.define( "forbidden_block", { description = "The blocks that are forbidden to break.", default = { "forbidden_arcanus:stella_arcanum" }, type = "table" } )
  settings.define( "valid_fuel", { description = "The items that can be consumed to refuel the turtle.", default = { "minecraft:charcoal", "minecraft:coal" }, type = "table" } )
  settings.define( "storage", { description = "The configured storage containers carried by the turtle.", default = {}, type = "table" } )
  settings.define( "refuel_all", { description = "If the turtle should consume the whole stack of fuel.", default = false, type = "boolean" } )
  settings.define( "do_not_store_items", { description = "List of items that should not be stored.", default = { [ "minecraft:bucket" ] = 1 }, type = "table" } )
  settings.define( "facing", { description = "The direction the turtle is facing.", default = { dx = 0, dz = 0 }, type = "table" } )
  settings.define( "position", { description = "The position of the turtle in the world.", default = vector.new( 0, 0, 0 ), type = "table" } )
  settings.define( "equipment_left", { description = "The equipment in the left slot", default = nil, type = "string" } )
  settings.define( "equipment_right", { description = "The equipment in the right slot", default = nil, type = "string" } )
  local default_slots = {}
  for i = 1, 16 do default_slots[ i ] = { item = nil, quantity = 0 } end
  settings.define( "slots", { description = "The inventory slots.", default = default_slots, type = "table" } )

  -- Load the settings file.
  settings.load( ".settings" )

  -- Get the settings value in memory.
  turtle.forbidden_block = settings.get( "forbidden_block" )
  turtle.valid_fuel = settings.get( "valid_fuel" )
  turtle.storage = settings.get( "storage" )
  turtle.refuel_all = settings.get( "refuel_all" )
  turtle.do_not_store_items = settings.get( "do_not_store_items" )
  --TTaskManager.current_task = settings.get( "task" )
  term.clear()
  turtle.load_settings()
end

--- Set and save a value in the settings file.
---@param key string
---@param value any
function o.set( key, value )
  settings.set( key, value )
  settings.save( FILE_NAME )
end

-- Get a value from the settings.
function o.get( key, value )
  return settings.get( key, value )
end

-- Unset a value in the settings and save de file.
function o.unset( key )
  settings.unset( key )
  settings.save( FILE_NAME )
end

--------------
-- settings -- 
--------------

function o.save_inventory()
  turtle.slots = turtle.get_slots()
  o.set( "slots", turtle.slots )
end

function o.save_facing()
  o.set( "facing", { dx = turtle.dx, dz = turtle.dz } )
end

function o.save_position()
  o.set( "position", vector.new( turtle.x, turtle.y, turtle.z ) )
end

function o.set_forbidden_block( forbidden_block )
  turtle.forbidden_block = forbidden_block
  settings.set( "forbidden_block", turtle.forbidden_block )
  settings.save( FILE_NAME )
end

function o.set_valid_fuel( valid_fuel )
  turtle.valid_fuel = valid_fuel
  o.set( "valid_fuel", turtle.valid_fuel )
end

function o.set_refuel_all( value )
  turtle.refuel_all = value
  o.set( "refuel_all", value )
end

--- Add a new storage container to the turtle's inventory.
---@param index integer
---@param new_storage { type: integer, filtered_items: string[]|nil }
function o.set_storage( index, new_storage )
  turtle.storage[ index ] = new_storage
  o.set( "storage", turtle.storage )
end

-- Remove a storage settings.
---@param index integer
function o.remove_storage( index )
  table.remove( turtle.storage, index )
  turtle.storage[ index ] = nil
  o.set( "storage", turtle.storage )
end

-- Add a new item as valid fuel. Remove it if already in the list.
function o.add_or_remove_valid_fuel( item_name )
  local was_removed = false

  -- Try to remove it.
  for k, v in pairs( turtle.valid_fuel ) do
    if v == item_name then
      table.remove( turtle.valid_fuel, k )
      was_removed = true
      break
    end
  end

  -- If not removed, add it.
  if not was_removed then
    table.insert( turtle.valid_fuel, item_name )
  end

  o.set_valid_fuel( turtle.valid_fuel )
end

-- Add a new item as forbidden block. Remove it if already in the list.
function o.add_or_remove_forbidden_block( block_name )
  local was_removed = false

  -- Try to remove it.
  for k, v in pairs( turtle.forbidden_block ) do
    if v == block_name then
      table.remove( turtle.forbidden_block, k )
      was_removed = true
      break
    end
  end

  -- If not removed, add it.
  if not was_removed then
    table.insert( turtle.forbidden_block, block_name )
  end

  o.set_forbidden_block( turtle.forbidden_block )
end

return o