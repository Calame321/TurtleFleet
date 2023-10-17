----------------
-- Fleet Mode --
----------------
local miner = require( "miner" )

-----------
-- Const --
-----------
local SIDES = redstone.getSides()

---------
-- Var --
---------
local is_last = false
local fleet_flatten_length = 32
local fleet_dig_out_depth = 32
local fleet_dig_out_width = 32

--------------
-- settings -- 
--------------

-- Load all the settings
function fleet_load_settings()
  load_fleet_flatten_length()
  load_fleet_dig_out_size()
end

function load_fleet_flatten_length()
  local loaded_fleet_flatten_length = settings.get( "fleet_flatten_length" )

  if loaded_fleet_flatten_length then
    fleet_flatten_length = loaded_fleet_flatten_length
  else
    set_fleet_flatten_length( 32 )
  end
end

function load_fleet_dig_out_size()
  local loaded_fleet_dig_out_depth = settings.get( "fleet_dig_out_depth" )
  local loaded_fleet_dig_out_width = settings.get( "fleet_dig_out_width" )

  if loaded_fleet_dig_out_depth then
    fleet_dig_out_depth = loaded_fleet_dig_out_depth
    fleet_dig_out_width = loaded_fleet_dig_out_width
  else
    set_fleet_dig_out_size( 32, 32 )
  end
end

function set_fleet_flatten_length( length )
  fleet_flatten_length = length
  settings.set( "fleet_flatten_length", length )
  settings.save( ".settings" )
end

function set_fleet_dig_out_size( depth, width )
  fleet_dig_out_depth = depth
  fleet_dig_out_width = width
  settings.set( "fleet_dig_out_depth", depth )
  settings.set( "fleet_dig_out_width", width )
  settings.save( ".settings" )
end

fleet_load_settings()

---------------------
-- Common Function --
---------------------
function equip_for_fleet_mode()
  -- Pick up configured storages.
  for k, v in pairs( turtle.storage ) do
    if v.type == turtle.FUEL_STORAGE then
      -- Up = fuel_storage or items
      turtle.empty_select( k )
      turtle.suckUp( 1 )
    elseif v.type == turtle.DROP_STORAGE then
      -- Down = drop_storage
      turtle.empty_select( k )
      turtle.suckDown( 1 )
    elseif v.type == turtle.FILTERED_DROP_STORAGE then
      -- Right = filtered_drop_storage
      turtle.turnRight()
      turtle.empty_select( k )
      turtle.suck( 1 )
      turtle.turnLeft()
    end
  end

  --Pick a bucket if available.
  turtle.select( 1 )
  turtle.turnLeft()
  turtle.suck( 1 )
  turtle.turnRight()

  -- If no fuel storage is set, up should be fuel items.
  if not turtle.has_fuel_chest() then
    turtle.suckUp()
  else
    -- Safeguard so the turtle dosen't break the chest trying to refuel.
    if turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel() < 100 then
      turtle.turn180()
      local fuel_storage_index = turtle.get_storage_index( turtle.FUEL_STORAGE )
      turtle.select( fuel_storage_index )
      turtle.wait_place( "forward" )
      turtle.suck()
      turtle.empty_select( fuel_storage_index )
      turtle.dig()
      turtle.turn180()
    end
  end
end

function get_paper_data()
  local paper_index = turtle.get_item_index( "minecraft:paper" )
  if paper_index ~= -1 then
    local paper_detail = turtle.getItemDetail( paper_index, true )
    return paper_detail.displayName
  end
  return nil
end

function place_next_turtle( job_id )
  -- Pick up a turtle.
  if not turtle.suck( 1 ) then
    is_last = true
  end

  turtle.force_back()

  if not is_last then
    local turtle_index = turtle.get_item_index( "computercraft:turtle" )

    if turtle_index == -1 then
      turtle_index = turtle.get_item_index( "computercraft:turtle_advanced" )
    end

    turtle.select( turtle_index )
    turtle.place()
    rs.setAnalogueOutput( "front", job_id )

    if turtle.get_item_index( "minecraft:paper" ) ~= -1 then
      turtle.select( turtle.get_item_index( "minecraft:paper" ) )
      turtle.drop()
      turtle.select( 1 )
    end

    sleep( 0.1 )
    peripheral.call( "front", "turnOn" )
    turtle.wait_for_signal( "front", job_id )
    rs.setAnalogueOutput( "front", 0 )
    sleep( 0.1 )
  end
end

function fleet_dig_out()
  -- get height with paper
  local paper_data = get_paper_data()
  fleet_dig_out_depth = 32
  fleet_dig_out_width = 32

  if paper_data then
    local d = mysplit( paper_data )
    fleet_dig_out_depth = tonumber( d[ 1 ] )
    fleet_dig_out_width = tonumber( d[ 2 ] )
  end

  equip_for_fleet_mode()
  place_next_turtle( 3 )

  -- Find next free spot
  turtle.turnRight()
  local found_spot = false

  while not found_spot do
    turtle.wait_up()
    turtle.wait_up()
    local s, d = turtle.inspectUp()

    if s and string.find( d.name, "turtle" ) then
      found_spot = true
      -- if this is the last turtle, give the signal!
      if is_last then
        rs.setAnalogueOutput( "top", 3 )
        sleep( 0.1 )
        rs.setAnalogueOutput( "top", 0 )
      end

      turtle.wait_down()
      turtle.wait_down()
    else
      turtle.wait_up()
    end
  end

  if not is_last then
    -- Wait for the signal from last turtle.
    turtle.wait_for_signal( "bottom", 3 )

    -- Give next turtle the signal.
    turtle.wait_up()
    turtle.wait_up()
    rs.setAnalogueOutput( "top", 3 )
    os.sleep( 0.1 )
    rs.setAnalogueOutput( "top", 0 )
    turtle.wait_down()
    turtle.wait_down()
  end

  miner.start_dig_out( fleet_dig_out_depth, fleet_dig_out_width )
end

----------------
-- Fleet Mode --
----------------
function has_flaten_fleet_setup()
  if turtle.get_info_paper_index() == -1 then
    print( "I don't have a piece of paper." )
    print( "I will use the default value:", fleet_flatten_length )
  end

  for i = 1, 4 do
    s, d = turtle.inspect()
    turtle.select( turtle.get_empty_slot_index() )
    turtle.suck( 1 )

    local item_detail = turtle.getItemDetail()
    turtle.drop()

    if item_detail and string.find( item_detail.name, "turtle" ) then
      return true
    end

    turtle.turnLeft()
  end
  
  return false
end

function fleet_flatten()
  turtle.do_not_store_items["minecraft:torch"] = 1
  turtle.do_not_store_items["minecraft:dirt"] = 2

  equip_for_fleet_mode()
  place_next_turtle( 7 )
  local paper_data = get_paper_data()

  if paper_data then
    fleet_flatten_length = tonumber( paper_data )
  end

  print( "flatten length:", fleet_flatten_length )

  -- Find next free spot
  turtle.turn180()
  local found_spot = false

  while not found_spot do
    local s, d = turtle.inspectDown()

    if s and string.find( d.name, "turtle" ) then
      turtle.force_forward()
    else
      turtle.force_down()
      found_spot = true
    end
  end
  turtle.turnLeft()

  -- Wait for the signal to start digging if it's not the last turtle.
  if not is_last then
    turtle.wait_for_signal( "right", 10 )
  end

  -- Relay the signal to the turtle in front.
  rs.setAnalogueOutput( "left", 10 )
  sleep( 0.1 )
  rs.setAnalogueOutput( "left", 0 )

  -- Start flatenning!
  turtle.select( 1 )
  turtle.force_forward()

  for y = 1, fleet_flatten_length / 4 do
    flat_one()

    -- if done, stop.
    if y ~= math.floor( fleet_flatten_length / 4 ) then
      turtle.force_forward()
    end
  end

  turtle.drop_in_storage()
  turtle.turnLeft()

  -- If it's not the last turtle, wait for a signal.
  if not is_last then
    print( "waiting for signal to transfer.")
    local rs_strength = turtle.wait_for_any_rs_signal( "back" )

    while rs_strength == 1 do
      turtle.drop_in_storage()

      -- Signal to the turtle that the storage is done.
      print( "Sending signal done storing." )
      rs.setAnalogueOutput( "back", 1 )
      sleep( 0.1 )
      rs.setAnalogueOutput( "back", 0 )

      rs_strength = turtle.wait_for_any_rs_signal( "back" )
    end
  end

  -- Wait for next turtle.
  local s, d = turtle.inspect()
  while not s or ( s and not string.find( d.name, "computercraft:turtle" ) ) do
    print( "waiting for next turtle. If I'm the last you can reboot me." )
    sleep( 5 )
    s, d = turtle.inspect()
  end
  print( "Other turtle is there!" )

  sleep( 2 )

  -- Drop in next turtle
  print( "Transfering my storage!" )
  for k, v in pairs( turtle.storage ) do
    if v.type == turtle.DROP_STORAGE then
      -- place the storage up.
      turtle.dig_all( "up" )
      turtle.select( k )
      turtle.wait_place( "up" )
      local empty_index = turtle.get_empty_slot_index()

      -- For all item in the storage.
      while turtle.suckUp() do
        -- if next turtle is full, sent redstone signal of strength 1.
        local has_dropped = turtle.drop()
        if not has_dropped then
          -- Tell the turtle to drop it's storage.
          rs.setAnalogueOutput( "front", 1 )
          os.sleep( 0.1 )
          rs.setAnalogueOutput( "front", 0 )

          -- Wait for the turtle to store the items.
          print( "Waiting fot the turtle in front to store its items.")
          turtle.wait_for_signal( "front", 1 )
          turtle.drop()
        end
      end

      -- Pick up the storage
      turtle.select( k )
      turtle.digUp()
    end
  end

  -- Tell the turtle to drop it's storage.
  rs.setAnalogueOutput( "front", 1 )
  sleep( 0.1 )
  rs.setAnalogueOutput( "front", 0 )

  -- Wait for the turtle to store the items.
  turtle.wait_for_signal( "front", 1 )

  -- when done, emit redstone strength 2
  print( "Transfering Done!" )
  rs.setAnalogueOutput( "front", 2 )
  sleep( 0.1 )
  rs.setAnalogueOutput( "front", 0 )

  print( "Done!" )
  os.sleep( 15 )
end

local fleet = {
  -- The first turtle to start the dig out.
  dig_out = function( height )
    is_first = true

    local paper_data = get_paper_data()
    local fleet_dig_out_depth = 32
    local fleet_dig_out_width = 32
    if paper_data then
      local d = mysplit( paper_data )
      fleet_dig_out_depth = tonumber( d[ 1 ] )
      fleet_dig_out_width = tonumber( d[ 2 ] )
    end

    print()
    print( "Starting dig out with: ", fleet_dig_out_depth, "depth,", fleet_dig_out_width, "width,", height, "height." )
    print()

    equip_for_fleet_mode()
    place_next_turtle( 3 )

    turtle.turnRight()
    for i = 1, height - 3 do
      turtle.force_up()
    end

    -- Wait for the signal to start.
    turtle.wait_for_signal( "bottom", 3 )

    miner.start_dig_out( fleet_dig_out_depth, fleet_dig_out_width )
  end;

  flatten = function()
    fleet_flatten()
  end;

  check_redstone_option = function()
    for s = 1, #SIDES do
      local redstone_option = rs.getAnalogueInput( SIDES[ s ] )

      if redstone_option == 3 then
        rs.setAnalogueOutput( "back", 3 )
        sleep( 0.1 )
        rs.setAnalogueOutput( "back", 0 )
        has_flaten_fleet_setup()
        fleet_dig_out()
      elseif redstone_option == 7 then
        rs.setAnalogueOutput( "back", 7 )
        sleep( 0.1 )
        rs.setAnalogueOutput( "back", 0 )
        has_flaten_fleet_setup()
        fleet_flatten()
        return true
      end
    end

    return false
  end;
}

return fleet