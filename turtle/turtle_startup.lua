------------
-- config --
------------
package.path = package.path .. ';/turtlefleet/ui/?.lua;/turtlefleet/utils/?.lua'

shell.run( "turtlefleet/turtle/advanced_turtle.lua" )
shell.run( "turtlefleet/turtle/pathfind.lua" )
station = dofile( "turtlefleet/stations/station.lua" )
treefarm = dofile( "turtlefleet/stations/treefarm.lua" )
job = dofile( "turtlefleet/jobs/job.lua" )
builder = dofile( "turtlefleet/jobs/builder.lua" )
cooker = dofile( "turtlefleet/jobs/cooker.lua" )
miner = dofile( "turtlefleet/jobs/miner.lua" )

-----------
-- Const --
-----------
local SIDES = redstone.getSides()

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
    turtle.select( 1 )
    turtle.force_down()
    turtle.dig()
  end

  turtle.force_back()
  replace_for_dirt()
  turtle.force_forward()
  replace_for_dirt()
  turtle.force_forward()
  replace_for_dirt()

  if turtle.is_inventory_filled_more_than( 0.5 ) then
    turtle.drop_in_storage()
  end
end

function dig_all_up()
  -- dig up until no more block up or average height reached
  while must_go_up() do
    height = height + 1

    if turtle.detectUp() then
      last_height = height
    end

    -- If there is water or lava, remove it!
    if not turtle.dig_all( "forward" ) then
      local s, d = turtle.inspect()
      if s and ( d.name == "minecraft:lava" or d.name == "minecraft:water" ) and d.state.level == 0 then
        turtle.force_forward()
        turtle.force_back()
      end
    end

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

function flaten_chunks( number_of_chunk )
  turtle.do_not_store_items["minecraft:torch"] = 1
  turtle.do_not_store_items["minecraft:dirt"] = 2

  for c = 1, number_of_chunk do
    flaten_chunk()
  end

  turtle.do_not_store_items = turtle.default_do_not_store_items
end

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
          turtle.is_block_name( "down", "minecraft:reeds" ) then turtle.digDown()
        end

        turtle.force_forward()
      end

      if turtle.is_block_name( "down", "minecraft:sugar_cane" ) or
        turtle.is_block_name( "down", "minecraft:reeds" ) then turtle.digDown()
      end

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

function set_cane_farm()
  turtle.wait_move( "forward" )
  turtle.turnRight()
  -- place first water
  turtle.digDown()
  turtle.select( 1 )
  turtle.placeDown()
  -- get a new source
  turtle.wait_move( "forward" )
  turtle.digDown()
  turtle.wait_move( "forward" )
  turtle.digDown()
  turtle.select( 2 )
  turtle.placeDown()
  turtle.wait_move( "back" )
  turtle.placeDown()
  turtle.select( 1 )
  os.sleep( 1 )
  turtle.placeDown()
end

----------------
-- Fleet Mode --
----------------
local flatten_length = 32

function check_redstone_option()
  for s = 1, #SIDES do
    local redstone_option = rs.getAnalogueInput( SIDES[ s ] )

    if redstone_option == 3 then
      rs.setAnalogueOutput( "back", 3 )
      os.sleep( 0.1 )
      rs.setAnalogueOutput( "back", 0 )
      has_flaten_fleet_setup()
      miner.fleet_dig_out()
    elseif redstone_option == 7 then
      rs.setAnalogueOutput( "back", 7 )
      os.sleep( 0.1 )
      rs.setAnalogueOutput( "back", 0 )
      has_flaten_fleet_setup()
      fleet_flatten()
      return true
    end
  end

  return false
end

function has_flaten_fleet_setup()
  if turtle.get_info_paper_index() == -1 then
    print( "I don't have a piece of paper." )
    print( "I will use the default values." )
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

  miner.equip_for_fleet_mode()
  local paper_data =  miner:place_next_turtle( 7 )

  if paper_data then
    flatten_length = tonumber( paper_data )
  end

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
  if not miner.is_last then
    turtle.wait_for_signal( "right", 10 )
  end

  -- Relay the signal to the turtle in front.
  rs.setAnalogueOutput( "left", 10 )
  os.sleep( 0.1 )
  rs.setAnalogueOutput( "left", 0 )

  -- Start flatenning!
  turtle.select( 1 )
  turtle.force_forward()

  for y = 1, flatten_length / 4 do
    flat_one()

    -- if done, stop.
    if y ~= math.floor( flatten_length / 4 ) then
      turtle.force_forward()
    end
  end

  turtle.drop_in_storage()
  turtle.turnLeft()

  -- If it's not the last turtle, wait for a signal.
  if not miner.is_last then
    print( "waiting for signal to transfer.")
    local rs_strength = turtle.wait_for_any_rs_signal( "back" )

    while rs_strength == 1 do
      turtle.drop_in_storage()
      
      -- Signal to the turtle that the storage is done.
      print( "Sending signal done storing." )
      rs.setAnalogueOutput( "back", 1 )
      os.sleep( 0.1 )
      rs.setAnalogueOutput( "back", 0 )
      
      rs_strength = turtle.wait_for_any_rs_signal( "back" )
    end
  end

  -- Wait for next turtle.
  local s, d = turtle.inspect()
  while not s or ( s and not string.find( d.name, "computercraft:turtle" ) ) do
    print( "waiting for next turtle. If I'm the last you can reboot me." )
    os.sleep( 5 )
    s, d = turtle.inspect()
  end
  print( "Other turtle is there!" )

  os.sleep( 2 )

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
  os.sleep( 0.1 )
  rs.setAnalogueOutput( "front", 0 )

  -- Wait for the turtle to store the items.
  turtle.wait_for_signal( "front", 1 )

  -- when done, emit redstone strength 2
  print( "Transfering Done!" )
  rs.setAnalogueOutput( "front", 2 )
  os.sleep( 0.1 )
  rs.setAnalogueOutput( "front", 0 )

  print( "Done!" )
  os.sleep( 15 )
end

----------
-- Menu --
----------
local w, h = term.getSize()
local current_menu = {}

function display_menu( menu )
  current_menu = menu
  term.clear()
  show_fuel_level()
  term.setCursorPos( 1, 1 )
  print( menu.path )
  print( menu.prompt )

  for i = 1, #menu.options do
    print( menu.options[ i ].name )
  end

  if current_menu.parent then
    term.setCursorPos( 1, h )
    write( "b - Go Back")
  end
end

-- Display the fuel level in the lower right corner of the screen.
function show_fuel_level()
  if turtle.getFuelLevel() == "unlimited" then
    local current_fuel = "Fuel: "
    local fg = "000000f0f0"
    local bg = "ffffff0f0f"
    term.setCursorPos( w - #current_fuel, h - 1 )
    term.blit( current_fuel, fg, bg )
    return
  end

  local current_fuel = "Fuel: " .. turtle.getFuelLevel() .. "/" .. turtle.getFuelLimit()
  term.setCursorPos( w - #current_fuel, h )
  write( current_fuel )
end

function show_tree_farm_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Tree Farm -" )
  print( "The turtle will plant trees and harvest them. It will also cook its own fuel." )
  print()
  print( "Length? (default = 15)")
  os.sleep( 0.2 )
  local input = read()
  local tree_farm_length = 15

  if input ~= "" then
    tree_farm_length = tonumber( input )
  end

  treefarm:start_tree_farm( tree_farm_length )
end

function show_digout_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Dig out -" )
  print( "This will dig a 3 blocks high area the size you specify.")
  print( "It's recomended to set some storages before if you can." )
  print()
  print( "Depth = ?")
  os.sleep( 0.2 )
  local input = read()
  local depth = tonumber( input )

  print( "Width = ?")
  os.sleep( 0.2 )
  input = read()
  local width = tonumber( input )
  miner:dig_out_start( depth, width )

  show_menu()
end

function show_fleet_digout_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Fleet Dig out -" )
  print( "This will dig a cubic area using multiple turtles (The height given divided by 3).")
  print( "This turtle should be placed on a chest to the left." )
  print( "The depth and width is given with a renamed piece of paper. ex: '32 16'. (else default 32 x 32 will be used)")
  print( "Press enter for the chests placement.")
  os.sleep( 0.2 )
  read()
  print( "Chests (not needed if not in settings):" )
  print( "- Up: Fuel" )
  print( "- Down: Drop Storage" )
  print( "- Front: Turtle Storage" )
  print( "- Right: Filtered Storage" )
  print( "- Left: Buckets (if there is going to be lava)" )
  print()
  os.sleep( 0.2 )
  print( "Height = ? (multiple of 3)")
  os.sleep( 0.2 )
  input = read()
  local height = tonumber( input )

  miner:fleet_dig_out_start( height )
  show_menu()
end

function show_flatten_chunk_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Flatten Chunk (16 x 16) -" )
  print( "This will flatten a 16 by 16 area. (from the back left corner). The extra height is to prevent floating blocks." )
  print( "It's recomended to set some storages before if you can." )
  print()
  print( "Number of chunk = ? (default = 1)")
  os.sleep( 0.2 )
  local input = read()
  local nb_chunk = 1
  if input ~= "" then nb_chunk = tonumber( input ) end
  
  print( "extra height = ? (default = 5)")
  os.sleep( 0.2 )
  input = read()
  local extra_height = 5
  if input ~= "" then
    extra_height = tonumber( input )
    last_average_height = extra_height
    initial_aditionnal_up = extra_height
  end

  flaten_chunks( nb_chunk )
  show_menu()
end

function show_fleet_flatten_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Fleet Flatten Chunk -" )
  print( "This will flatten an area the width of the number of turtle used." )
  print( "This turtle should be placed on a chest to the left." )
  print( "The length is given with a renamed piece of paper. (by step of 4) ex: '64'.")
  print( "Press enter for the chests placement.")
  os.sleep( 0.2 )
  read()
  print( "Chests (not needed if not in settings):" )
  print( "- Up: Fuel" )
  print( "- Down: Drop Storage" )
  print( "- Front: Turtle Storage" )
  print( "- Right: Filtered Storage" )
  print( "- Left: Buckets (if there is going to be lava)" )
  print()
  print( "Give a paper renamed with the length then press enter to start.")
  os.sleep( 0.2 )
  read()

  if has_flaten_fleet_setup() then
    fleet_flatten()
  else
    print( "The Fleet flatten setup is invalid." )
  end

  show_menu()
end

-- Vein mine
function show_vein_mine_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Vein Mine -" )
  print( "This will mine all block specified that are connected by a side. (Diagonal dosen't work.)" )
  print()

  print( "Block to mine = ? (default = The block in front)")
  os.sleep( 0.2 )
  local input = read()
  if input == "" then
    local found_block, block_data = turtle.inspectDir( "forward" )
    if found_block then
      input = block_data.name
    end
  end

  miner:vein_mine( "forward", input )
  show_menu()
end

-- Place Ceiling
function start_place_ceiling()
  builder:place_floor( "up" )
  show_menu()
end

-- Branch mining
function show_branch_mining()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Branch Mining -" )
  print( "For this one, the turtle need to be facing a chest. It will mine the number of branches of specified of the specified length." )
  print()

  print( "The turtle should turn:" )
  print( "1 = left (default)" )
  print( "2 = right")
  os.sleep( 0.2 )
  local input = read()
  local branch_side = "left"

  if input == "2" then
    branch_side = "left"
  end

  print( "Number of branches? (default = 20)" )
  os.sleep( 0.2 )
  local input = read()
  if input ~= "" then
    miner.branch_mine_quantity = tonumber( input )
  end

  print( "Length of a branche? (default = 80)")
  os.sleep( 0.2 )
  input = read()
  if input ~= "" then
    miner.branch_mine_length = tonumber( input )
  end

  miner:branch_mining( branch_side )
  show_menu()
end

function show_current_config_page()
  display_current_storage()
  term.setCursorPos( 1, h )
  write( "press enter." )
  os.sleep( 0.2 )
  read()

  display_current_valid_fuel()
  term.setCursorPos( 1, h )
  write( "press enter." )
  os.sleep( 0.2 )
  read()

  display_current_forbidden_block()
  term.setCursorPos( 1, h )
  write( "press enter." )
  os.sleep( 0.2 )
  read()

  show_menu()
end

function display_current_storage()
  term.clear()
  local current_title = "- current storage, slot: type -"
  term.setCursorPos( w - #current_title, 1 )
  print( current_title )
  local line_y = 2
  for i = 1, 16 do
    if turtle.storage[ i ] then
      local s = i .. ": " .. turtle.storage_names[ turtle.storage[ i ].type ]
      term.setCursorPos( w - #s, line_y )
      write( s )
      line_y = line_y + 1
    end
  end
end

function display_current_valid_fuel()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Refuel All - " )
  if turtle.refuel_all then
    print( "Full stack." )
  else
    print( "2 fuel item." )
  end

  local current_title = "- Current Valid Fuel -"
  term.setCursorPos( w - #current_title, 1 )
  print( current_title )
  local line_y = 2
  for k, v in pairs( turtle.valid_fuel ) do
    term.setCursorPos( w - #v, line_y )
    write( v )
    line_y = line_y + 1
  end
end

function display_current_forbidden_block()
  term.clear()
  local current_title = "- Current Forbidden Blocks -"
  term.setCursorPos( w - #current_title, 1 )
  print( current_title )
  local line_y = 2
  for k, v in pairs( turtle.forbidden_block ) do
    term.setCursorPos( w - #v, line_y )
    write( v )
    line_y = line_y + 1
  end
end

function show_set_storage_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Storage -" )
  print( "Here you can give a storage that maintain it's content when broken, like a ShulkerBox, to the turtle." )
  print( "To add a new storage, enter witch slot in the turtle's inventory it will be." )
  print()
  print( "Index: *Enter existing index to remove." )
  os.sleep( 0.2 )
  local input = read()
  local inventory_slot = tonumber( input )

  -- Check if need to remove
  local was_removed = false
  for k, v in pairs( turtle.storage ) do
    if k == inventory_slot then
      turtle.remove_storage_config( inventory_slot )
      was_removed = true
      break
    end
  end

  if not was_removed then
    term.clear()
    term.setCursorPos( 1, 1 )
    print( "What type is it?" )
    print( "1: The turtle will pick fuel from it." )
    print( "2: It will drop it's inventory in the storage when full." )
    print( "3: Filtered, can be used to drop item in a trash or a special storage." )
    print()
    print( "Type:" )
    os.sleep( 0.2 )
    input = read()
    local new_storage = { type = tonumber( input ) }

    if new_storage.type == 3 then
      term.clear()
      term.setCursorPos( 1, 1 )
      print( "Place the item to be filtered in the inventory and press enter.")
      os.sleep( 0.2 )
      input = read()
      new_storage.filtered_items = {}

      for i = 1, 16 do
        local item = turtle.getItemDetail( i )
        if item then
          table.insert( new_storage.filtered_items, item.name )
        end
      end
    end
    
    turtle.set_storage( inventory_slot, new_storage )
  end

  print( "Setup another storage? y, n")
  os.sleep( 0.2 )
  input = read()

  if input == "y" then
    show_set_storage_page()
  end

  show_menu()
end

function show_set_valid_fuel_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Valid Fuel -" )
  print( "A turtle can consume any fuel a furnace can burn." )
  print( "Enter the item name or place it in the first slot of the turtle's inventory then press enter." )
  print( "*same to remove it." )
  print()
  print( "Item name:" )
  os.sleep( 0.2 )
  local input = read()
  
  -- if the input is empty, try to get the first item name
  if input == "" then
    turtle.select( 1 )
    local item_data = turtle.getItemDetail()

    if item_data then
      input = item_data.name
    end
  end

  -- if input not empty, add the new item
  if input ~= "" then
    turtle.add_or_remove_valid_fuel( input )
  end

  display_current_valid_fuel()
  print( "Add another item? y, n")
  os.sleep( 0.2 )
  input = read()

  if input == "y" then
    show_set_valid_fuel_page()
  end

  show_menu()
end

function show_set_refuel_all_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Refuel All -" )
  print( "Do you want your turtle to eat a full stack of fuel when it needs it?" )
  print()
  print( "y, n" )
  os.sleep( 0.2 )
  local input = read()

  turtle.set_refuel_all( input == "y" )
  show_menu()
end

function show_set_forbidden_block_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Forbidden -" )
  print( "Blocks that the turtle should not mine! Used if you want to mine diamond ore with fortune or for stuff that can explode." )
  print( "Enter block name or place it in front of the turtle then press enter." )
  print( "*same to remove it." )
  os.sleep( 0.2 )
  local input = read()
  
  -- if the input is empty, try to get the block in front
  if input == "" then
    local has_block, block_data = turtle.inspect()

    if has_block then
      input = block_data.name
    end
  end

  -- if input not empty, add the new block
  if input ~= "" then
    turtle.add_or_remove_forbidden_block( input )
  end

  display_current_forbidden_block()
  print( "Add another block? y, n")
  os.sleep( 0.2 )
  input = read()

  if input == "y" then
    show_set_forbidden_block_page()
  end

  show_menu()
end

function get_installer()
  shell.run( "pastebin run TBpm1C8V" )
end

function old_show_menu()
  -- Go to position
  if args[1] == "goto" then
    turtle.pathfind_to(
        vector.new( tonumber( args[2] ), tonumber( args[3] ), tonumber( args[4] ) ), false
     )
  -- setup a mine
  elseif args[1] == "setupMine" then
    miner:setup_mine( vector.new( tonumber( args[2] ), tonumber( args[3] ), tonumber( args[4] ) ) )
  -- start mining
  elseif args[1] == "mine" then
    miner:mine()
  else
    print( "What?... bye." )
  end
end

local all_menu = {
  main_menu = {
    path = "Menu",
    prompt = "Choose an option:",
    parent = nil,
    options = {
      { key = "one", name = "1 - Stations", menu = "menu_stations" },
      { key = "two", name = "2 - Miner", menu = "menu_miner" }, 
      { key = "three", name = "3 - Builder", menu = "menu_builder" },
      { key = "four", name = "4 - Fleet Mode", menu = "menu_fleet" },
      { key = "five", name = "5 - Configurations", menu = "menu_config" }
    }
  },
  menu_stations = {
    path = "Menu -> Stations",
    prompt = "Choose a station:",
    parent = "main_menu",
    options = {
      { key = "one", name = "1 - Tree Farm", action = show_tree_farm_page },
      { key = "two", name = "2 - Cooking", action = cooker.start_cooking },
      { key = "three", name = "3 - Farming", menu = "menu_farms" }
    }
  },
  menu_farms = {
    path = "Menu -> Stations -> Farms",
    prompt = "Choose a farm:",
    parent = "menu_stations",
    options = {
      { key = "one", name = "1 - Farmer's Delight: Rice", action = rice_farm },
      { key = "two", name = "2 - Minecraft: Sugar Cane", action = cane_farm },
    }
  },
  menu_miner = {
    path = "Menu -> Miner",
    prompt = "Choose a job:",
    parent = "main_menu",
    options = {
      { key = "one", name = "1 - Dig Out", action = show_digout_page },
      { key = "two", name = "2 - Flatten chunk", action = show_flatten_chunk_page },
      { key = "three", name = "3 - Vein Mine", action = show_vein_mine_page },
      { key = "four", name = "4 - Branch Mining", action = show_branch_mining },
      { key = "five", name = "5 - Tunnel", action = miner.dig_tunnel }
    }
  },
  menu_builder = {
    path = "Menu -> Builder",
    prompt = "Choose a job:",
    parent = "main_menu",
    options = {
      { key = "one", name = "1 - Place Floor", action = builder.place_floor },
      { key = "two", name = "2 - Place Ceiling", action = start_place_ceiling },
      { key = "three", name = "3 - Place Wall", action = builder.place_wall }
    }
  },
  menu_fleet = {
    path = "Menu -> Fleet",
    prompt = "Choose a job:",
    parent = "main_menu",
    options = {
      { key = "one", name = "1 - Fleet Dig Out", action = show_fleet_digout_page },
      { key = "two", name = "2 - Fleet Flatten", action = show_fleet_flatten_page }
    }
  },
  menu_config = {
    path = "Menu -> Settings",
    prompt = "Choose an option:",
    parent = "main_menu",
    options = {
      { key = "one", name = "1 - See Current Settings", action = show_current_config_page },
      { key = "two", name = "2 - Installer", action = get_installer },
      { key = "three", name = "3 - Storage", action = show_set_storage_page },
      { key = "four", name = "4 - Valid Fuel", action = show_set_valid_fuel_page },
      { key = "five", name = "5 - Refuel All", action = show_set_refuel_all_page },
      { key = "six", name = "6 - Forbidden Block", action = show_set_forbidden_block_page }
    }
  }
}

function show_menu()
  load_settings()
  display_menu( all_menu.main_menu )

  -- Timer to display time
  local clock_timer = os.startTimer( 1 )

  while true do
    event = { os.pullEvent() }
    -- is a key is pressed
    if event[ 1 ] == "key" then
      on_key_pressed( keys.getName( event[ 2 ] ) )
    elseif event[ 1 ] == "timer" and event[ 2 ] == clock_timer then
      clock_timer = os.startTimer( 1 )
    elseif event[ 1 ] == "modem_connected" then
      print( "modem_connected" )
    elseif event[ 1 ] == "rednet_message" then
      print( "rednet_message" )
    end
  end
end

function on_key_pressed( key_name )
  -- test
  if key_name == "p" then
    turtle.drop_in_storage()
  end

  -- go back
  if current_menu.parent and key_name == "b" then
    display_menu( all_menu[ current_menu.parent ] )
  end

  -- sub menu or actions
  for i = 1, #current_menu.options do
    if current_menu.options[ i ] ~= nil and key_name == current_menu.options[ i ].key then
      -- sub menu
      if current_menu.options[ i ].menu ~= nil then
        display_menu( all_menu[ current_menu.options[ i ].menu ] )
        os.sleep( 0.1 )
        return
      -- action
      elseif current_menu.options[ i ].action ~= nil then
        current_menu.options[ i ].action()
        os.sleep( 0.1 )
        return
      end
    end
  end
end

check_redstone_option()

show_menu()