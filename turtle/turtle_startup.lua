------------
-- config --
------------
package.path = package.path .. ';/turtlefleet/ui/?.lua;/turtlefleet/utils/?.lua'

if pcall( settings.save ) then
  shell.run( "turtlefleet/turtle/advanced_turtle.lua" )
  shell.run( "turtlefleet/turtle/pathfind.lua" )
  station = dofile( "turtlefleet/stations/station.lua" )
  treefarm = dofile( "turtlefleet/stations/treefarm.lua" )
else
  print( "Minecraft 1.12.2" )
  shell.run( "turtlefleet/turtle/advanced_turtle_1_12_2.lua" )
  shell.run( "turtlefleet/turtle/pathfind.lua" )
  station = dofile( "turtlefleet/stations/station.lua" )
  treefarm = dofile( "turtlefleet/stations/treefarm_1_12_2.lua" )
end

job = dofile( "turtlefleet/jobs/job.lua" )
builder = dofile( "turtlefleet/jobs/builder.lua" )
cooker = dofile( "turtlefleet/jobs/cooker.lua" )
miner = dofile( "turtlefleet/jobs/miner.lua" )
main_menu = require( "main_menu" )
update = require( "update" )

-----------
-- Const --
-----------
local SIDES = redstone.getSides()

----------------------------
-- global helper function --
----------------------------
function mysplit( str, sep )
  if sep == nil then sep = "%s" end

  local t = {}

  for str in string.gmatch( str, "([^" .. sep .. "]+)" ) do table.insert( t, str ) end

  return t
end

function has_value( table, val )
  for i = 1, #table do if tostring( table[i] ) == tostring( val ) then return true end end

  return false
end

--------------
-- Settings --
--------------
local map = {}

function load_settings()
  if not fs.exists( "map" ) then
    local file = fs.open( "map", "w" )
    file.close()
  end

  local f = fs.open( "map", "r" )
  local line = f.readLine()
  while line ~= nil do
    local l = mysplit( line )
    map_add( vector.new( l[1], l[2], l[3] ), l[4] )
  end
end

function save_map()
  local file = fs.open( "map", "w" )

  for x, kx in pairs( map ) do
    for y, ky in pairs( kx ) do
      for z, kz in pairs( ky ) do
        file.writeLine( tostring( x ) .. " " .. tostring( y ) .. " " .. tostring( z ) .. " " .. kz )
      end
    end
  end

  file.flush()
  file.close()
end

---------
-- Map --
---------
function map_remove( pos )
  if not map[pos.x] or not map[pos.x][pos.y] or not map[pos.x][pos.y][pos.z] then return end
  table.remove( map[pos.x][pos.y], pos.z )
end

function map_add( pos, block_name )
  if not map[pos.x] then map[pos.x] = {} end
  if not map[pos.x][pos.y] then map[pos.x][pos.y] = {} end
  print( block_name .. " added for " .. tostring( pos ) )
  map[pos.x][pos.y][pos.z] = block_name
end

function map_get( pos )
  -- If a value is not set, return nil
  if not map[pos.x] or not map[pos.x][pos.y] or not map[pos.x][pos.y][pos.z] then return nil end
  return map[pos.x][pos.y][pos.z]
end

----------------
-- Decoration --
----------------

local initial_aditionnal_up = 5
local last_average_height = 10
local aditionnal_up = 5
local last_height = 0
local height = 0
local torch_counter = 0
local flat_stuff_to_keep = {}
flat_stuff_to_keep["minecraft:coal"] = 1
flat_stuff_to_keep["minecraft:charcoal"] = 1
flat_stuff_to_keep["minecraft:torch"] = 1
flat_stuff_to_keep["minecraft:dirt"] = 2
flat_stuff_to_keep["enderstorage:ender_chest"] = 2

function flat_one()
  replace_for_dirt()
  height = 0
  last_height = 0

  dig_all_up()
  turtle.force_forward()
  turtle.force_forward()
  dig_all_up()

  -- change last height based on the height 
  if last_height < last_average_height then
    last_average_height = last_average_height - 1
  else
    last_average_height = last_height
  end

  for h = 1, height do
    turtle.force_down()
    turtle.dig()
  end

  turtle.force_back()
  replace_for_dirt()
  turtle.force_forward()
  replace_for_dirt()
  turtle.force_forward()
  replace_for_dirt()
end

function dig_all_up()
  -- dig up until no more block up or average height reached
  while must_go_up() do
    height = height + 1
    if turtle.detectUp() then last_height = height end
    turtle.dig()
    turtle.force_up()
  end
end

function must_go_up()
  if turtle.detect() or turtle.detectUp() or height < last_average_height then
    aditionnal_up = initial_aditionnal_up
    return true
  end

  if aditionnal_up > 0 then
    aditionnal_up = aditionnal_up - 1
    return true
  end

  aditionnal_up = initial_aditionnal_up
  return false
end

function replace_for_dirt()
  if not turtle.is_block_name( "down", "minecraft:grass_block" ) and
      not turtle.is_block_name( "down", "minecraft:dirt" ) then
    local dirt_index = turtle.get_item_index( "minecraft:dirt" )

    if dirt_index > 0 then
      turtle.select( dirt_index )
      turtle.digDown()
      turtle.placeDown()
      turtle.select( 1 )
    end
  end
end

function flaten_chunk()
  turtle.force_forward()
  turtle.turnRight()

  for x = 1, 16 do
    for y = 1, 4 do
      flat_one()
      if turtle.is_inventory_full() then turtle.drop_in_enderchest( flat_stuff_to_keep ) end
      if y < 4 then turtle.force_forward() end
      flat_place_torch()
    end

    -- dont need to change row if at the end
    if x < 16 then
      if x % 2 == 0 then
        turtle.turnRight()
      else
        turtle.turnLeft()
      end
      turtle.force_forward()
      if x % 2 == 0 then
        turtle.turnRight()
      else
        turtle.turnLeft()
      end
    end
  end

  turtle.turnRight()
end

function flat_place_torch()
  -- Place a torch
  if torch_counter == 5 then
    torch_counter = 0

    local torch_index = turtle.get_item_index( "minecraft:torch" )

    if torch_index > 0 then
      turtle.select( torch_index )
      turtle.turn180()
      turtle.place()
      turtle.turn180()
      turtle.select( 1 )
    end
  else
    torch_counter = torch_counter + 1
  end
end

function flaten_chunks( number_of_chunk ) for c = 1, number_of_chunk do flaten_chunk() end end

-------------
-- Farming --
-------------
function rice_farm()
  while true do
    turtle.forward()
    turtle.turnRight()

    for x = 1, 16 do
      for y = 1, 15 do
        local has_rice, rice = turtle.inspectDown()

        if has_rice and rice.state.age == 3 then turtle.digDown() end

        turtle.forward()
      end

      local has_rice, rice = turtle.inspectDown()
      if has_rice and rice.state.age == 3 then turtle.digDown() end

      -- dont need to change row if at the end
      if x < 16 then
        if x % 2 == 0 then
          turtle.turnRight()
          turtle.force_forward()
          turtle.turnRight()
        else
          turtle.turnLeft()
          turtle.force_forward()
          turtle.turnLeft()
        end
      else
        turtle.turnLeft()

        for i = 1, 16 do turtle.forward() end

        turtle.turn180()

        local rice_index = get_item_index( "rice_panicle" )
        while rice_index > 0 do
          turtle.select( rice_index )
          if not turtle.dropDown() then
            print( "The chest is full..." )
            read()
          end
          rice_index = get_item_index( "rice_panicle" )
        end
      end
    end

    os.sleep( 120 )
  end
end

function cane_farm()
  while true do
    turtle.force_forward()
    turtle.turnRight()

    for x = 1, 16 do
      for y = 1, 15 do
        if turtle.is_block_name( "down", "minecraft:sugar_cane" ) or
            turtle.is_block_name( "down", "minecraft:reeds" ) then turtle.digDown() end

        turtle.force_forward()
      end

      if turtle.is_block_name( "down", "minecraft:sugar_cane" ) or
          turtle.is_block_name( "down", "minecraft:reeds" ) then turtle.digDown() end

      -- dont need to change row if at the end
      if x < 16 then
        if x % 2 == 0 then
          turtle.turnRight()
          turtle.force_forward()
          turtle.turnRight()
        else
          turtle.turnLeft()
          turtle.force_forward()
          turtle.turnLeft()
        end
      else
        turtle.turnLeft()

        for i = 1, 16 do turtle.wait_forward() end

        turtle.turn180()

        local index = turtle.get_item_index( "sugar_cane" )
        if index == -1 then index = turtle.get_item_index( "minecraft:reeds" ) end
        while index > 0 do
          turtle.select( index )
          if not turtle.dropDown() then
            print( "The chest is full..." )
            read()
          end
          index = turtle.get_item_index( "sugar_cane" )
          if index == -1 then index = turtle.get_item_index( "minecraft:reeds" ) end
        end
      end
    end

    os.sleep( 222 )
  end
end

----------------
-- Fleet Mode --
----------------
local flatten_length = 32
local is_last = false
local last_pos

function check_redstone_option()
  for s = 1, #SIDES do
    local redstone_option = rs.getAnalogueInput( SIDES[s] )

    if redstone_option == 3 then
      local data = turtle.getItemDetail( 3, true )
      turtle.select( 3 )
      turtle.dropUp()
      os.sleep( 0.5 )
      rs.setAnalogueOutput( "top", 3 )
      os.sleep( 0.5 )
      rs.setAnalogueOutput( "top", 0 )
      local d = mysplit( data.displayName )
      miner:dig_out( tonumber( d[1] ), tonumber( d[2] ) )
    elseif redstone_option == 7 then
      rs.setAnalogueOutput( "back", 7 )
      os.sleep( 0.1 )
      has_flaten_fleet_setup()
      rs.setAnalogueOutput( "back", 0 )
      fleet_flatten()
      return true
    elseif redstone_option == 6 then
      update()
      rs.setAnalogueOutput( "back", 1 )
      return true
    end
  end

  return false
end

function has_flaten_fleet_setup()
  local s, d = turtle.inspectUp()
  local has_chest_up = s and string.find( d.name, "chest" )
  s, d = turtle.inspectDown()
  local has_chest_down = s and string.find( d.name, "chest" )

  if has_chest_up and has_chest_down then
    for i = 1, 4 do
      s, d = turtle.inspect()
      local has_chest_front = s and string.find( d.name, "chest" )

      if has_chest_front then
        turtle.set_position( 0, 0, 0, turtle.NORTH )
        return true
      end

      turtle.turnLeft()
    end

    os.reboot()
  end

  return false
end

function fleet_flatten()
  turtle.suckUp()

  if not turtle.suck() then is_last = true end

  turtle.force_back()

  if is_last then
    local paper_index = turtle.get_item_index( "minecraft:paper" )
    if paper_index > 0 then
      local paper_detail = turtle.getItemDetail( paper_index, true )
      flatten_length = tonumber( paper_detail.displayName )
    end
  else
    place_mining_turtle()
  end

  turtle.turnLeft()
  goto_next_free_spot()
  turtle.turn180()

  if not is_last then turtle.wait_for_signal( "back", 10 ) end

  rs.setAnalogueOutput( "front", 10 )
  os.sleep( 0.05 )
  rs.setAnalogueOutput( "front", 0 )
  turtle.turnRight()

  for y = 1, flatten_length / 4 do
    flat_one()
    turtle.force_forward()
  end
end

function goto_next_free_spot()
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
end

function place_mining_turtle()
  turtle.select( turtle.get_item_index( "computercraft:turtle" ) )
  turtle.place()
  rs.setAnalogueOutput( "front", 7 )

  local paper_index = turtle.get_item_index( "minecraft:paper" )
  if paper_index > 0 then
    local paper_detail = turtle.getItemDetail( paper_index, true )
    flatten_length = tonumber( paper_detail.displayName )
    turtle.select( paper_index )
    turtle.drop()
    turtle.select( 1 )
  end

  os.sleep( 0.05 )
  peripheral.call( "front", "turnOn" )
  turtle.wait_for_signal( "front", 7 )
  rs.setAnalogueOutput( "front", 0 )
  os.sleep( 0.10 )
end

----------
-- Menu --
----------
function run_menu()
  -- Timer to display time
  local clock_timer = os.startTimer( 1 )

  while true do
    event = { os.pullEvent() }
    if event[1] == "timer" and event[2] == clock_timer then
      clock_timer = os.startTimer( 1 )
    elseif event[1] == "modem_connected" then
      print( "modem_connected" )
    elseif event[1] == "rednet_message" then
      print( "rednet_message" )
    end

    main_menu.draw( event )
  end
end

----------
-- Menu --
----------
main_menu.top_menu_bar.add_menu_item( "file", "1.Computer", "1" )
main_menu.top_menu_bar.add_sub_item( "file", "reboot", "Reboot", "r", function() os.reboot() end )
main_menu.top_menu_bar.add_sub_item(
    "file", "shutdown", "Shutdown", "s", function() os.shutdown() end
 )
main_menu.top_menu_bar.add_sub_item(
    "file", "returnOs", "Return to OS", "o", function() os.exit() end
 )

main_menu.top_menu_bar.add_menu_item( "turtle", "2.Turtle", "2" )
main_menu.top_menu_bar.add_sub_item(
    "turtle", "canefarm", "0.Cane Farm", "0", function() cane_farm() end
 )
main_menu.top_menu_bar.add_sub_item(
    "turtle", "treefarm", "1.Tree Farm", "1", function() treefarm:start_tree_farm() end
 )
main_menu.top_menu_bar.add_sub_item(
    "turtle", "veinmine", "2.Vein Mine", "2",
    function() miner:vein_mine( "forward", "micenraft:coal_ore" ) end
 )
main_menu.top_menu_bar.add_sub_item(
    "turtle", "digout", "3.Dig Out", "3", function() miner:dig_out_start( 3, 3 ) end
 )
main_menu.top_menu_bar.add_sub_item(
    "turtle", "placefloor", "4.Place Floor", "4", function() builder:place_floor( args[2] ) end
 )
main_menu.top_menu_bar.add_sub_item(
    "turtle", "placewall", "5.Place Wall", "5", function() builder:place_wall() end
 )
main_menu.top_menu_bar.add_sub_item(
    "turtle", "minebranch", "6.Mine Branch", "6", function() miner:mine_branch() end
 )
main_menu.top_menu_bar.add_sub_item(
    "turtle", "flatchunk", "7.Flatten Chunk", "7", function() flaten_chunks( 1 ) end
 )
main_menu.top_menu_bar.add_sub_item(
    "turtle", "cooking", "8.Start Cooking", "8", function() cooker:start_cooking() end
 )
main_menu.top_menu_bar.add_sub_item(
    "turtle", "branchmining", "9.Branch Mining", "9", function() miner:branch_mining() end
 )

main_menu.icon_grid.add_icon( "inventory", "Inventory", function() end, "inventory" )
main_menu.icon_grid.add_icon( "mining", "Mining", function() end, "mine" )
main_menu.icon_grid.add_icon( "building", "Building", function() end, "tree" )

function show_menu()
  term.clear()
  load_settings()
  print( "What should I do ?" )
  print( "1 - Tree Farm. [optionnal -> farm length]" )
  print( "2 - Vein Mine. [block name]" )
  print( "3 - Dig Out. [depth width]" )
  print( "4 - Place Floor. [ 'up' for ceiling ]" )
  print( "5 - Place Wall." )
  print( "6 - Mine Branch." )
  print( "7 - Flatten 16 x 16. [chunks qty, xtra height]" )
  print( "8 - Start cooking." )
  print( "9 - branch mining." )
  print( "10 - Farm [ 1 = rice, 2 = sugar_cane ]" )
  local input = read()
  local args = mysplit( input )

  -- Set position
  if args[1] == "pos" then
    turtle.set_position(
      tonumber( args[2] ), tonumber( args[3] ), tonumber( args[4] ), tonumber( args[5] )
    )

  -- Go to position
  elseif args[1] == "goto" then
    turtle.pathfind_to(
        vector.new( tonumber( args[2] ), tonumber( args[3] ), tonumber( args[4] ) ), false
     )
  
  -- setup a mine
  elseif args[1] == "setupMine" then
    miner:setup_mine( vector.new( tonumber( args[2] ), tonumber( args[3] ), tonumber( args[4] ) ) )
  
  -- start mining
  elseif args[1] == "mine" then
    miner:mine()

  -- update the program
  elseif args[1] == "update" then
    update.master()

  -- look at the gui
  elseif args[1] == "v" then
    run_menu()

  -- Tree Farm
  elseif args[1] == "1" then
    treefarm:start_tree_farm( tonumber( args[2] ) )

  -- Vein mine
  elseif args[1] == "2" then
    miner:vein_mine( "forward", args[2] )

  -- Dig out
  elseif args[1] == "3" then
    if args[4] == nil then
      miner:dig_out_start( tonumber( args[2] ), tonumber( args[3] ) )
    else
      miner:dig_out_start( tonumber( args[2] ), tonumber( args[3] ), tonumber( args[4] ) )
    end

  -- Place floor
  elseif args[1] == "4" then
    builder:place_floor( args[2] )

  -- Place Wall
  elseif args[1] == "5" then
    builder:place_wall()

  -- Mine one branch
  elseif args[1] == "6" then
    miner:mine_branch()

  -- Flatten chunk
  elseif args[1] == "7" then
    local number_of_chunk = tonumber( args[2] )
    if number_of_chunk == nil then number_of_chunk = 1 end
    local extra_height = tonumber( args[3] )
    if extra_height ~= nil then
      last_average_height = extra_height
      initial_aditionnal_up = extra_height
    end
    if has_flaten_fleet_setup() then
      fleet_flatten()
    else
      flaten_chunks( number_of_chunk )
    end

  -- Cooking
  elseif args[1] == "8" then
    cooker:start_cooking()

  -- Branch mining
  elseif args[1] == "9" then
    miner:branch_mining( args[2] )

  -- Crop farm
  elseif args[1] == "10" then
    if args[2] == "1" then
      rice_farm()
    else
      cane_farm()
    end

  -- Tunnel
  elseif args[1] == "t" then
    miner:dig_tunnel()

  else
    print( "What?... bye." )
  end
end

local has_task = false
-- Check if has redstone analog signal
if check_redstone_option() then has_task = true end

-- Check if was doing a task
local job, data1, data2, data3 = turtle.load_job()
if job then
  print( "Turtle resume job: " .. job )
  print( "Delete the job file to stop it." )

  if job == "treefarm" then
    treefarm:resume( data1 )
  elseif job == "dig_out" then
    miner:dig_out_resume( data1, data2, data3 )
  end

  has_task = true
end

if not has_task then show_menu() end
