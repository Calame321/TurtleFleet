----------------------------
-- global helper function --
----------------------------
function mysplit( str, sep )
  if sep == nil then
    sep = "%s"
  end

  local t = {}

  for str in string.gmatch( str, "([^" .. sep .. "]+)" ) do
    table.insert( t, str )
  end

  return t
end

------------
-- Miner --
------------

---------------
-- Vein Mine --
---------------

function vein_mine( from, block )
  if turtle.is_inventory_full() then turtle.drop_in_storage() end

  -- up
  if turtle.is_block_name( "up", block ) then
    turtle.force_move( "up" )
    vein_mine( "up", block )
  end

  -- forward
  if turtle.is_block_name( "forward", block ) then
    turtle.force_forward()
    vein_mine( "forward", block )
  end

  -- down
  if turtle.is_block_name( "down", block ) then
    turtle.force_down()
    vein_mine( "down", block )
  end

  -- left
  turtle.turnLeft()

  if turtle.is_block_name( "forward", block ) then
    turtle.force_forward()
    vein_mine( "forward", block )
  end

  -- right
  turtle.turn180()

  if turtle.is_block_name( "forward", block ) then
    turtle.force_forward()
    vein_mine( "forward", block )
  end

  turtle.turnLeft()
  turtle.reverse( from )
end

-------------
-- Dig Out --
-------------
do_width_remaining = 0
do_row_remaining = 0
do_width_start = 0
digout_row_done = 0

function dig_out( depth, width )
  turtle.force_forward()
  turtle.turnRight()
  do_width_remaining = width
  do_width_start = width
  do_row_remaining = depth
  digout_row_done = 0
  dig_out_loop()
end

function dig_out_loop()
  while do_row_remaining ~= 0 do
    dig_out_row()
    if do_row_remaining ~= 1 then
      dig_out_change_row()
    else
      do_row_remaining = 0
    end
  end

  -- Return start.
  if digout_row_done % 2 == 0 then
    turtle.turn180()
    for i = 1, do_width_start - 1 do
      turtle.wait_forward()
    end
  end

  turtle.turnRight()
  turtle.drop_in_storage()
end

function dig_out_row()
  while do_width_remaining ~= 0 do
    turtle.select( 1 )

    if not turtle.dig_all( "up" ) then
      local s, d = turtle.inspectUp()
      if s and ( d.name == "minecraft:lava" or d.name == "minecraft:water" ) and d.state.level == 0 then
        turtle.force_up()
        turtle.force_down()
      end
    end

    if not turtle.dig_all( "down" ) then
      local s, d = turtle.inspectDown()
      if s and ( d.name == "minecraft:lava" or d.name == "minecraft:water" ) and d.state.level == 0 then
        turtle.force_down()
        turtle.force_up()
      end
    end

    if do_width_remaining ~= 1 then
      turtle.force_forward()
    end

    do_width_remaining = do_width_remaining - 1
  end
end

function dig_out_change_row()
  if digout_row_done % 2 == 0 then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end

  turtle.force_forward()

  if  digout_row_done % 2 == 0 then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end

  do_width_remaining = do_width_start
  do_row_remaining = do_row_remaining - 1
  digout_row_done = digout_row_done + 1
end

-------------------
-- Branch Mining --
-------------------
local branch_mine_length = 80
local branch_mine_quantity = 20

function check_ore( direction )
  if turtle.is_block_tag( direction, "forge:ores" ) or turtle.is_block_tag( direction, "_ore" ) then
    local success, data = turtle.inspectDir( direction )
    local ore_name = data.name

    for b = 1, #turtle.forbidden_block do
      if ore_name == turtle.forbidden_block[ b ] then
        return false
      end
    end

    turtle.force_move( direction )
    vein_mine( direction, ore_name )
  end

  return true
end

function mine_branch()
  local found_forbidden_ore = false
  local depth = 0

  for i = 1, branch_mine_length do
    depth = depth + 1
    if not check_ore( "forward" ) then found_forbidden_ore = true end
    if not found_forbidden_ore then turtle.force_forward() end
    if turtle.is_inventory_full() then turtle.drop_in_storage() end
    if not check_ore( "up" ) then found_forbidden_ore = true end
    if not check_ore( "down" ) then found_forbidden_ore = true end
    turtle.turnLeft()
    if not check_ore( "forward" ) then found_forbidden_ore = true end
    turtle.turn180()
    if not check_ore( "forward" ) then found_forbidden_ore = true end
    turtle.turnLeft()

    if found_forbidden_ore then
      print( "FOUND DO_NOT_MINE ORE !!!!" )
      break
    end
  end

  for i = 0, depth - 1 do
    turtle.force_move( "back" )
    if found_forbidden_ore then turtle.digDown() end
  end

  return found_forbidden_ore
end

function branch_mine( side )
  local branch_index = 0

  for b = 1, branch_mine_quantity do
    turtle.turn180()

    for i = 1, ( branch_index * 4 ) do turtle.force_forward() end

    if side == "left" then
      turtle.turnRight()
    else
      turtle.turnLeft()
    end

    mine_branch()

    if side == "left" then
      turtle.turnRight()
    else
      turtle.turnLeft()
    end

    for i = 1, ( branch_index * 4 ) do turtle.force_forward() end

    empty_inventory()
    branch_index = branch_index + 1
  end
end

function empty_inventory()
  for i = 1, 16 do
    -- If it's a storage slot and a drop storage, drop it's content in the chest
    if turtle.is_storage_slot( i ) then
      if turtle.get_storage_type( i ) == turtle.DROP_STORAGE then
        -- place the storage above
        turtle.dig_all( "up" )
        turtle.select( i )
        turtle.placeUp()

        -- get all the item in the storage above and drop them in the chest
        while turtle.suckUp() do
          if not turtle.drop() then
            print( "Please, make some place in the chest !!" )
            while not turtle.drop() do os.sleep( 5 ) end
          end
        end

        -- Pick up the storage
        turtle.digUp()
      end
    else
      local item = turtle.getItemDetail( i )

      if item and not turtle.is_valid_fuel( item.name ) and item.name ~= "minecraft:bucket" then
        turtle.select( i )

        if not turtle.drop() then
          print( "Please, make some place in the chest !!" )
          while not turtle.drop() do os.sleep( 5 ) end
        end
      end
    end
  end
end

------------
-- Mining --
------------
local mine_start_position
local mine_level = 6
local mine_setup = false
local mine_layer = 1
local mine_direction = 0

function setup_mine( mine_position )
  mine_start_position = mine_position
end

function get_mine_y()
  return ( mine_layer * 2 ) + 4
end

function get_branch_entrance_pos( branch_index )
  local x = mine_start_position.x + ( ( ( ( mine_layer % 2 ) * 2 ) + 2 ) * ( mine_direction % 2 ) )
  local y = get_mine_y()
  local z = mine_start_position.z + ( ( ( ( mine_layer % 2 ) * 2 ) + 2 ) * ( ( 1 + mine_direction ) % 2 ) )
end

function mine()
  if not mine_setup then
    print( "Need to setup the mine." )
    print( "My pos = " .. tostring( pos.coords ) )
    print( "Mine pos = " .. tostring( mine_start_position ) )
    go_to_mine_start()
    turtle.turn( turtle.NORTH )
    dig_mine_shaft()
    go_to_output_chest()
    turtle.turn( turtle.WEST )
    drop_inventory()
    mine_setup = true
  end

  go_to_mine_start()
  go_down_the_mine()
  turtle.turn( mine_direction )
  find_next_branch()
  -- branch_mine()
end

function find_next_branch()
  local branch_index = 0

  while true do
    -- TODO: Force goto
    turtle.pathfind_to( get_branch_entrance_pos( branch_index ), true )
    turtle.turn( turtle.LEFT )

    local s, d = turtle.inspect()

    if (not s or d.name ~= "minecraft:cobblestone") then return true end

    turtle.turn( turtle.RIGHT )
    branch_index = branch_index + 1

    if branch_index * 4 >= branch_mine_quantity then return false end
  end

  return false
end

function go_to_mine_start() turtle.pathfind_to( mine_start_position, false ) end

function go_to_output_chest()
  local mine_output_position = vector.new(
    mine_start_position.x,
    mine_start_position.y,
    mine_start_position.z - 1
  )
  turtle.pathfind_to( mine_output_position, false )
end

function dig_mine_shaft()
  turtle.turn( turtle.NORTH )
  for i = 1, 58 do
    turtle.force_move( "down" )
    turtle.dig()
  end
end

function go_down_the_mine()
  local mine_level_position = vector.new( mine_start_position.x, 6, mine_start_position.z )
  turtle.pathfind_to( mine_level_position, false )
end

function drop_inventory()
  for i = 1, 16 do
    local item = turtle.getItemDetail( i )
    if item and item.count > 0 then
      turtle.select( i )

      if item.name == "minecraft:coal" or item.name == "minecraft:charcoal" then
        turtle.dropUp()
      else
        local chest_has_place = turtle.drop()

        while not chest_has_place do
          os.sleep( 5 )
          chest_has_place = turtle.drop()
        end
      end
    end
  end

  turtle.select( 1 )
  turtle.suckUp()
end

---------------
-- Tunneling --
---------------
local next_torch = 2

function have_tunneling_materials()
  local has_fuel = false
  local has_torch = false

  for i = 1, 16 do
    local item = turtle.getItemDetail( i )

    if item then
      if item.name == "minecraft:torch" then
        has_chests = true
      elseif string.find( item.name, "coal" ) then
        has_fuel = true
      end
    end
  end

  return has_torch and has_fuel
end

-------------
-- Flatten --
-------------
local initial_aditionnal_up = 5
local last_average_height = 10
local aditionnal_up = 5
local last_height = 0
local flatten_height = 0
local torch_counter = 0
local flatten_cover_water = settings.get( "flatten_cover_water" )
local flatten_cover_air = settings.get( "flatten_cover_air" )
local wait_for_more_dirt = false

function flat_one()
  replace_for_dirt()
  flatten_height = 0
  last_height = 0

  dig_all_up()
  turtle.force_forward()
  turtle.force_forward()
  dig_all_up()

  -- change last flatten_height based on the flatten_height 
  print( "last_height:", last_height )
  print( "last_average_height:",last_average_height)
  if last_height < last_average_height then
    last_average_height = last_average_height - 1
  else
    last_average_height = last_height
  end

  for h = 1, flatten_height do
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
  -- dig up until no more block up or average flatten_height reached
  while must_go_up() do
    flatten_height = flatten_height + 1

    if turtle.detectUp() then
      last_height = flatten_height
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
  if turtle.detect() or turtle.detectUp() or flatten_height < last_average_height then
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
  local s, d = turtle.inspectDown()

  if not s and not flatten_cover_air then
    return
  end

  if s and ( ( not flatten_cover_water and d.name == "minecraft:water" and d.state.level == 0 ) or ( d.name == "minecraft:grass_block" or d.name == "minecraft:dirt" ) ) then
    return
  end

  local dirt_index = turtle.get_item_index( "minecraft:dirt" )

  if wait_for_more_dirt then
    while dirt_index == -1 do
      print( "Give me more dirt, then press enter." )
      read()
      dirt_index = turtle.get_item_index( "minecraft:dirt" )
    end
  end

  if dirt_index > 0 then
    if s then turtle.digDown() end
    turtle.select( dirt_index )
    turtle.placeDown()
    turtle.select( 1 )
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

-- public functions
local miner = {
  start_dig_out = function( depth, width )
    dig_out( depth, width )
  end;

  start_flaten_chunks = function( nb_chunk, extra_height )
    last_average_height = extra_height
    initial_aditionnal_up = extra_height
    flaten_chunks( nb_chunk )
  end;

  start_vein_mine = function( from, block )
    vein_mine( from, block )
  end;

  start_branch_mining = function( side, branch_nb, branch_length )
    branch_mine_quantity = branch_nb
    branch_mine_length = branch_length
    branch_mine( side )
  end;

  -- Dig an infinite tunnel and place torch every 11 blocks
  dig_tunnel = function()
    -- infinite loop
    while true do
      turtle.dig_all( "forward" )
      turtle.force_forward()
      turtle.dig_all( "up" )
      next_torch = next_torch - 1
  
      if next_torch == 0 then
        local torch_index = turtle.get_item_index( "minecraft:torch" )
        if torch_index == -1 then
          print( "Give me more torch please!" )
  
          while torch_index == -1 do
            os.sleep( 5 )
            torch_index = turtle.get_item_index( "minecraft:torch" )
          end
        end
  
        -- Place the torch behind so it dosen't attach to the block in front above.
        turtle.force_back()
        local torch_placed = turtle.placeUp( torch_index )
        local cobble_index = turtle.get_item_index( "minecraft:cobblestone" )

        if not torch_placed and cobble_index ~= -1 then
          turtle.force_up()
          turtle.placeRight( cobble_index )
          turtle.force_down()
          turtle.placeUp( torch_index )
        end
  
        turtle.force_forward()
        next_torch = 11
      end
    end
  end;
}


return miner