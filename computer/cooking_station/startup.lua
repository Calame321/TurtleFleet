local FURNACE_INPUT = 1
local FURNACE_FUEL = 2
local FURNACE_OUTPUT = 3

settings.define( "input", { description = "The name of the input chest.", default = nil, type = "string" } )
settings.define( "ouput", { description = "The name of the output chest", default = nil, type = "string" } )
settings.define( "fuel", { description = "The name of the fuel chest", default = nil, type = "string" } )

local input
local output
local fuel
local furnaces = {}

local function get_chests()
  local input_name = settings.get( "input" )
  local fuel_name = settings.get( "fuel" )
  local output_name = settings.get( "output" )
  if input_name == nil then
    print( "input is null")
    for k, v in ipairs( peripheral.getNames() ) do
      if string.find( v, "chest" ) then
        local chest = peripheral.wrap( v )
        if chest.getItemDetail( 1 ) == nil then
          print( "found output chest" )
          output = chest
          settings.set( "output", v )
          settings.save()
        elseif chest.getItemDetail( 1 ).name == "minecraft:cobblestone" then
          print( "found input chest" )
          input = chest
          settings.set( "input", v )
          settings.save()
        elseif string.find( chest.getItemDetail( 1 ).name, "coal" ) then
          print( "found fuel chest" )
          fuel = chest
          settings.set( "fuel", v )
          settings.save()
        end
      end
    end
  else
    print( "Loaded from settings.")
    input = peripheral.wrap( input_name )
    output = peripheral.wrap( output_name )
    fuel = peripheral.wrap( fuel_name )
  end
end

local function get_slot_item_count( inventory, index )
  local item = inventory.getItemDetail( index )
  if item == nil then
    return 0
  end
  return item.count
end

local function get_furnaces()
  print( "Getting connected furnaces.")
  local all_peripherals = peripheral.getNames()
  furnaces = {}
  for k, v in ipairs( all_peripherals ) do
    if string.find( v, "furnace" ) then
      local furnace = {
        name = v,
        peripheral = peripheral.wrap( v )
      }
      furnace.update = function()
        furnace.input_count = get_slot_item_count( furnace.peripheral, FURNACE_INPUT )
        furnace.fuel_count = get_slot_item_count( furnace.peripheral, FURNACE_FUEL )
        furnace.output_count = get_slot_item_count( furnace.peripheral, FURNACE_OUTPUT )
      end
      furnace.update()
      table.insert( furnaces, furnace )
    end
  end
end

--- Return the first available item from the inventory.
---@param inventory any
---@return integer|nil index The item index.
---@return unknown # The item data.
local function get_first_item( inventory )
  for i = 1, inventory.size() do
    local item = inventory.getItemDetail( i )
    if item then
      return i, item
    end
  end
  return nil, nil
end

--- Gets the furnace with the lowest amount of items in the input slot and that has space for 8 more items.
---@return any|nil
local function get_lowest_input_furnace()
  local lowest = 64 - 8
  local lowest_furnace = nil
  for k, v in ipairs( furnaces ) do
    -- If it's lower.
    if v.input_count < lowest then
      lowest_furnace = v
      lowest = v.input_count
    end
  end
  return lowest_furnace
end

-- Put items in the input chest in the furnaces.
local function input_to_furnaces()
  local furnace = get_lowest_input_furnace()
  -- Push 8 item from input.
  local input_index, input_item = get_first_item( input )
  if input_index then
    local fuel_index, fuel_item = get_first_item( fuel )
    if fuel_index then
      input.pushItems( peripheral.getName( furnace.peripheral ), input_index, 8, FURNACE_INPUT )
      fuel.pushItems( peripheral.getName( furnace.peripheral ), fuel_index, 1, FURNACE_FUEL )
      furnace.update()
    end
  end
end

--- Collects all furnaces output.
local function collect()
  for _, v in ipairs( furnaces ) do
    if v.peripheral.getItemDetail( FURNACE_OUTPUT ) then
      output.pullItems( v.name, FURNACE_OUTPUT )
      v.update()
    end
  end
end

get_chests()
get_furnaces()

print( "input is: " .. peripheral.getName( input ) )
print( "output is: " .. peripheral.getName( output ) )
print( "fuel is: " .. peripheral.getName( fuel ) )

while true do
  for i = 1, #furnaces do
    input_to_furnaces()
  end
  collect()
  sleep( 0 )
end