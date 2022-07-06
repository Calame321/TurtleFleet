------------
-- Miner --
------------
miner = job:new()

miner.chunk_per_region = 5 -- from center
miner.branch_mine_length = 16 * miner.chunk_per_region

miner.stuff_to_keep = {}
miner.stuff_to_keep["minecraft:coal"] = 2
miner.stuff_to_keep["minecraft:charcoal"] = 2
miner.stuff_to_keep["enderstorage:ender_chest"] = 2

function miner:vein_mine( from, block )
  -- up
  if turtle.is_block_name( "up", block ) then
    turtle.force_move( "up" )
    miner:vein_mine( "up", block )
  end

  -- forward
  if turtle.is_block_name( "forward", block ) then
    turtle.force_forward()
    miner:vein_mine( "forward", block )
  end

  -- down
  if turtle.is_block_name( "down", block ) then
    turtle.force_down()
    miner:vein_mine( "down", block )
  end

  -- left
  turtle.turnLeft()

  if turtle.is_block_name( "forward", block ) then
    turtle.force_forward()
    miner:vein_mine( "forward", block )
  end

  -- right
  turtle.turn180()

  if turtle.is_block_name( "forward", block ) then
    turtle.force_forward()
    miner:vein_mine( "forward", block )
  end

  turtle.turnLeft()
  turtle.reverse( from )
end

-------------
-- Dig Out --
-------------
miner.do_width_remaining = 0
miner.do_row_remaining = 0
miner.do_width_start = 0

function miner:dig_out_start( depth, width, height )
  print(
      "Starting dig out with: " .. tostring( depth ) .. " " .. tostring( width ) .. " " ..
          tostring( height )
   )
  if height == nil or height == 3 then
    miner:dig_out( depth, width )
    return
  end

  if height % 3 ~= 0 then
    print( "The height must be divisible by 3." )
    return
  end

  local layer = height / 3

  local info_paper_index = turtle.get_info_paper_index()
  if turtle.has_drop_chest() and turtle.has_fuel_chest() and turtle.has_turtle_chest() and
      info_paper_index > 0 then
    print( "everithing is ok, starting!" )
    for i = 1, layer - 1 do
      turtle.force_up()
      turtle.select( turtle.turtle_chest_index )
      turtle.dig_all( "up" )
      turtle.wait_place( "up" )
      turtle.suckUp( 1 )
      turtle.select( turtle.turtle_chest_index )
      turtle.digUp()
      turtle.select( turtle.get_item_index( "turtle" ) )
      turtle.wait_place( "down" )
      turtle.select( turtle.enderchest_index )
      turtle.dropDown( 1 )
      turtle.select( turtle.fuel_chest_index )
      turtle.dropDown( 1 )
      turtle.select( info_paper_index )
      turtle.dropDown()
      rs.setAnalogueOutput( "bottom", 3 )
      os.sleep( 0.5 )
      peripheral.call( "bottom", "turnOn" )
      turtle.wait_for_signal( "bottom", 3 )
      turtle.force_up()
      turtle.force_up()
    end
  else
    print(
        "You must provide " .. tostring( layer ) .. " enderchest for dropping stuff in slot 1, " ..
            tostring( layer ) ..
            " enderchest for fuel in slot 2, a enderchest for turtles in slot 3 and a paper renamed with depth and width."
     )
  end

  miner:dig_out( depth, width )
end

function miner:dig_out( depth, width )
  turtle.set_position( 0, 0, 0, turtle.NORTH )
  turtle.force_forward()
  turtle.turnRight()
  miner.do_width_remaining = width
  miner.do_width_start = width
  miner.do_row_remaining = depth
  turtle.save_job( "dig_out", miner.do_row_remaining, miner.do_width_start, miner.do_width_remaining )
  miner:dig_out_loop()
  fs.delete( "job" )
end

function miner:dig_out_resume( depth, width, remaining )
  miner.do_row_remaining = depth
  miner.do_width_start = width
  miner.do_width_remaining = remaining
  if turtle.y > 0 then turtle.force_down() end
  if turtle.y < 0 then turtle.force_up() end
  miner:dig_out_loop()
  fs.delete( "job" )
end

function miner:dig_out_loop()
  while miner.do_row_remaining ~= 0 do
    miner:dig_out_row()
    if miner.do_row_remaining ~= 1 then
      miner:dig_out_change_row()
    else
      miner.do_row_remaining = 0
    end
  end

  return_start()
end

function miner:dig_out_row()
  while miner.do_width_remaining ~= 0 do
    turtle.dig_all( "up" )
    turtle.dig_all( "down" )

    local s, d = turtle.inspectUp()
    if s and d.name == "minecraft:lava" and d.state.level == 0 then
      turtle.force_up()
      turtle.force_down()
    end
    s, d = turtle.inspectDown()
    if s and d.name == "minecraft:lava" and d.state.level == 0 then
      turtle.force_down()
      turtle.force_up()
    end

    if turtle.is_inventory_full() then turtle.drop_in_enderchest( miner.stuff_to_keep ) end
    if miner.do_width_remaining ~= 1 then turtle.force_forward() end
    miner.do_width_remaining = miner.do_width_remaining - 1
    turtle.save_job(
        "dig_out", miner.do_row_remaining, miner.do_width_start, miner.do_width_remaining
     )
  end
end

function miner:dig_out_change_row()
  if turtle.x == 0 then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
  miner.do_width_remaining = miner.do_width_start
  miner.do_row_remaining = miner.do_row_remaining - 1
  turtle.force_forward()
  turtle.save_job( "dig_out", miner.do_row_remaining, miner.do_width_start, miner.do_width_remaining )
  if turtle.x == 0 then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
end

function return_start()
  if turtle.x > 0 then
    turtle.turn( turtle.WEST )
    while turtle.x ~= 0 do turtle.force_forward() end
  end
  turtle.turn( turtle.NORTH )
  turtle.drop_in_enderchest()
end

-------------------
-- Branch Mining --
-------------------

function miner:check_ore( direction )
  local ore_tag = "forge:ores"

  if turtle.is_block_tag( direction, ore_tag ) then
    local success, data = turtle.inspectDir( direction )
    local ore_name = data.name

    for b = 1, #turtle.DO_NOT_MINE do if ore_name == turtle.DO_NOT_MINE[b] then return false end end

    turtle.force_move( direction )
    miner:vein_mine( direction, ore_name )
  end

  return true
end

function miner:mine_branch()
  local found_forbidden_ore = false
  local depth = 0

  for i = 1, miner.branch_mine_length do
    depth = depth + 1
    if not miner:check_ore( "forward" ) then found_forbidden_ore = true end
    if not found_forbidden_ore then turtle.force_forward() end
    if not miner:check_ore( "up" ) then found_forbidden_ore = true end
    if not miner:check_ore( "down" ) then found_forbidden_ore = true end
    turtle.turnLeft()
    if not miner:check_ore( "forward" ) then found_forbidden_ore = true end
    turtle.turn180()
    if not miner:check_ore( "forward" ) then found_forbidden_ore = true end
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

function miner:empty_inventory()
  for i = 1, 16 do
    local slot = turtle.getItemDetail( i )

    if slot and not turtle.is_valid_fuel( slot.name ) then
      turtle.select( i )

      if not turtle.drop() then
        print( "Please, make some place in the chest !!" )

        while not turtle.drop() do os.sleep( 10 ) end
      end
    end
  end
end

function miner:branch_mining( side )
  local branch_index = 0

  for b = 1, miner.branch_mine_length / 4 do
    turtle.turn180()

    for i = 1, (branch_index * 4) do turtle.force_forward() end

    if side == "left" then
      turtle.turnLeft()
    else
      turtle.turnRight()
    end

    miner:mine_branch()

    if side == "left" then
      turtle.turnLeft()
    else
      turtle.turnRight()
    end

    for i = 1, (branch_index * 4) do turtle.force_forward() end

    miner:empty_inventory()
    branch_index = branch_index + 1
  end
end

------------
-- Mining --
------------

local mining_state = "going_down"
local mine_start_position
local mine_level = 6
local mine_setup = false
local mine_layer = 1
local mine_direction = 0

function miner:setup_mine( mine_position )
  mine_start_position = mine_position
  miner:save_mine()
end

function miner:get_mine_y() return (mine_layer * 2) + 4 end

function miner:get_branch_entrance_pos( branch_index )
  local x = mine_start_position.x + ((((mine_layer % 2) * 2) + 2) * (mine_direction % 2))
  local y = miner:get_mine_y()
  local z = mine_start_position.z + ((((mine_layer % 2) * 2) + 2) * ((1 + mine_direction) % 2))
end

function miner:mine()
  miner:load_mine()

  if not mine_setup then
    print( "Need to setup the mine." )
    print( "My pos = " .. tostring( pos.coords ) )
    print( "Mine pos = " .. tostring( mine_start_position ) )
    miner:go_to_mine_start()
    turtle.turn( turtle.NORTH )
    miner:dig_mine_shaft()
    miner:go_to_output_chest()
    turtle.turn( turtle.WEST )
    miner:drop_inventory()
    mine_setup = true
    miner:save_mine()
  end

  miner:go_to_mine_start()
  miner:go_down_the_mine()
  turtle.turn( mine_direction )
  miner:find_next_branch()
  -- branch_mine()
end

function miner:find_next_branch()
  mining_state = "find_next_branch"
  local branch_index = 0

  while true do
    -- TODO: Force goto
    turtle.pathfind_to( miner:get_branch_entrance_pos( branch_index ), true )
    turtle.turn( LEFT )

    local s, d = turtle.inspect()

    if (not s or d.name ~= "minecraft:cobblestone") then return true end

    turtle.turn( RIGHT )
    branch_index = branch_index + 1

    if branch_index * 4 >= miner.branch_mine_length then return false end
  end

  return false
end

function miner:go_to_mine_start() turtle.pathfind_to( mine_start_position, false ) end

function miner:go_to_output_chest()
  local mine_output_position = vector.new(
                                   mine_start_position.x, mine_start_position.y,
                                   mine_start_position.z - 1
                                )
  turtle.pathfind_to( mine_output_position, false )
end

function miner:dig_mine_shaft()
  turtle.turn( turtle.NORTH )
  for i = 1, 58 do
    turtle.force_move( "down" )
    turtle.dig()
  end
end

function miner:go_down_the_mine()
  mining_state = "going_down"
  miner:save_mine()
  local mine_level_position = vector.new( mine_start_position.x, 6, mine_start_position.z )
  turtle.pathfind_to( mine_level_position, false )
end

function miner:drop_inventory()
  mining_state = "drop_inventory"
  miner:save_mine()

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

function miner:load_mine()
  if not fs.exists( "mine" ) then
    local file = fs.open( "mine", "w" )
    file.close()
  end

  local file = fs.open( "mine", "r" )
  mining_state = file.readLine()
  local start_pos_split = mysplit( file.readLine() )
  mine_start_position = vector.new( start_pos_split[1], start_pos_split[2], start_pos_split[3] )
  mine_level = tonumber( file.readLine() )
  mine_setup = "true" == file.readLine()
  mine_layer = tonumber( file.readLine() )
  file.close()
end

function miner:save_mine()
  local file = fs.open( "mine", "w" )
  file.writeLine( mining_state )
  print( "Save mine pos: " .. tostring( mine_start_position ) )
  file.writeLine(
      tostring( mine_start_position.x ) .. " " .. tostring( mine_start_position.y ) .. " " ..
          tostring( mine_start_position.z )
   )
  file.writeLine( tostring( mine_level ) )
  file.writeLine( tostring( mine_setup ) )
  file.writeLine( tostring( mine_layer ) )
  file.flush()
  file.close()
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

function miner:load_tunnel()
  if not fs.exists( "tunnel" ) then
    return
  end

  local file = fs.open( "tunnel", "r" )
  next_torch = tonumber( file.readLine() )
  file.close()
end

function miner:save_tunnel()
  local file = fs.open( "tunnel", "w" )
  file.writeLine( tostring( next_torch ) )
  file.flush()
  file.close()
end

-- Dig an infinite tunnel and place torch every 11 blocks
function miner:dig_tunnel()
  -- infinite loop
  while true do
    -- check for forbidden ores
    local found_forbidden_ore = false
    if not miner:check_ore( "forward" ) then found_forbidden_ore = true end
    if not miner:check_ore( "up" ) then found_forbidden_ore = true end

    if found_forbidden_ore then
      print( "FOUND DO_NOT_MINE ORE !!!!" )
      return
    end

    turtle.dig_all( "forward" )
    turtle.force_forward()
    turtle.dig_all( "up" )

    next_torch = next_torch - 1
    miner:save_tunnel()

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
        turtle.placeUp()
      end
      turtle.force_forward()

      next_torch = 11
    end
  end
end

return miner
