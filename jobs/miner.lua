miner = job:new()

----------------------------
-- global helper function --
----------------------------
function miner:mysplit( str, sep )
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

miner.branch_mine_length = 80
miner.branch_mine_quantity = 20

function miner:vein_mine( from, block )
  if turtle.is_inventory_full() then turtle.drop_in_storage() end

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


----------------
-- Fleet Mode --
----------------
miner.is_last = false

function miner:equip_for_fleet_mode()
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

function miner:get_paper_data()
  local paper_index = turtle.get_item_index( "minecraft:paper" )
  if paper_index ~= -1 then
    local paper_detail = turtle.getItemDetail( paper_index, true )
    return paper_detail.displayName
  end
  return nil
end

function miner:place_next_turtle( job_id )
  -- Pick up a turtle.
  if not turtle.suck() then
    miner.is_last = true
  end

  turtle.force_back()
  
  if not miner.is_last then
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

    os.sleep( 0.1 )
    peripheral.call( "front", "turnOn" )
    turtle.wait_for_signal( "front", job_id )
    rs.setAnalogueOutput( "front", 0 )
    os.sleep( 0.1 )
  end
end

-------------
-- Dig Out --
-------------
miner.do_width_remaining = 0
miner.do_row_remaining = 0
miner.do_width_start = 0
miner.digout_row_done = 0

function miner:dig_out_start( depth, width )
  miner:dig_out( depth, width )
end

-- The first turtle to start the dig out.
function miner:fleet_dig_out_start( height )
  miner.is_first = true

  local paper_data = miner:get_paper_data()
  local depth = 32
  local width = 32
  if paper_data then
    local d = miner:mysplit( paper_data )
    depth = tonumber( d[ 1 ] )
    width = tonumber( d[ 2 ] )
  end

  print()
  print( "Starting dig out with: ", depth, "depth,", width, "width,", height, "height." )
  print()

  miner:equip_for_fleet_mode()
  miner:place_next_turtle( 3 )
  
  turtle.turnRight()
  for i = 1, height - 3 do
    turtle.force_up()
  end

  -- Wait for the signal to start.
  turtle.wait_for_signal( "bottom", 3 )

  miner:dig_out( depth, width )
end

function miner:fleet_dig_out()
  -- get height with paper
  local paper_data = miner:get_paper_data()
  local depth = 32
  local width = 32
  if paper_data then
    local d = miner:mysplit( paper_data )
    depth = tonumber( d[ 1 ] )
    width = tonumber( d[ 2 ] )
  end
  
  miner:equip_for_fleet_mode()
  miner:place_next_turtle( 3 )

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
      if miner.is_last then
        rs.setAnalogueOutput( "top", 3 )
        os.sleep( 0.1 )
        rs.setAnalogueOutput( "top", 0 )
      end

      turtle.wait_down()
      turtle.wait_down()
    else
      turtle.wait_up()
    end
  end

  if not miner.is_last then
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

  miner:dig_out( depth, width )
end

function miner:dig_out( depth, width )
  turtle.force_forward()
  turtle.turnRight()
  miner.do_width_remaining = width
  miner.do_width_start = width
  miner.do_row_remaining = depth
  miner.digout_row_done = 0
  miner:dig_out_loop()
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

  -- Return start.
  if miner.digout_row_done % 2 == 0 then
    turtle.turn180()
    for i = 1, miner.do_width_start - 1 do
      turtle.wait_forward()
    end
  end

  turtle.turnRight()
  turtle.drop_in_storage()
end

function miner:dig_out_row()
  while miner.do_width_remaining ~= 0 do
    turtle.select( 1 )

    if not turtle.dig_all( "up" ) then
      local s, d = turtle.inspectUp()
      if s and ( d.name == "minecraft:lava" or d.name == "minecraft:water" ) and d.state.level == 0 then
        turtle.force_up()
        turtle.force_down()
      end
    end

    if not turtle.dig_all( "down" ) then
      s, d = turtle.inspectDown()
      if s and ( d.name == "minecraft:lava" or d.name == "minecraft:water" ) and d.state.level == 0 then
        turtle.force_down()
        turtle.force_up()
      end
    end

    if miner.do_width_remaining ~= 1 then
      turtle.force_forward()
    end

    miner.do_width_remaining = miner.do_width_remaining - 1
  end
end

function miner:dig_out_change_row()
  if miner.digout_row_done % 2 == 0 then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end
  
  turtle.force_forward()

  if  miner.digout_row_done % 2 == 0 then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end

  miner.do_width_remaining = miner.do_width_start
  miner.do_row_remaining = miner.do_row_remaining - 1
  miner.digout_row_done = miner.digout_row_done + 1
end

-------------------
-- Branch Mining --
-------------------
function miner:check_ore( direction )
  local ore_tag = "forge:ores"

  if turtle.is_block_tag( direction, ore_tag ) then
    local success, data = turtle.inspectDir( direction )
    local ore_name = data.name

    for b = 1, #turtle.forbidden_block do
      if ore_name == turtle.forbidden_block[ b ] then
        return false
      end
    end

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
    if turtle.is_inventory_full() then turtle.drop_in_storage() end
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

function miner:branch_mining( side )
  local branch_index = 0

  for b = 1, miner.branch_mine_quantity do
    turtle.turn180()

    for i = 1, (branch_index * 4) do turtle.force_forward() end

    if side == "left" then
      turtle.turnRight()
    else
      turtle.turnLeft()
    end

    miner:mine_branch()

    if side == "left" then
      turtle.turnRight()
    else
      turtle.turnLeft()
    end

    for i = 1, (branch_index * 4) do turtle.force_forward() end

    miner:empty_inventory()
    branch_index = branch_index + 1
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

function miner:setup_mine( mine_position )
  mine_start_position = mine_position
end

function miner:get_mine_y() return (mine_layer * 2) + 4 end

function miner:get_branch_entrance_pos( branch_index )
  local x = mine_start_position.x + ((((mine_layer % 2) * 2) + 2) * (mine_direction % 2))
  local y = miner:get_mine_y()
  local z = mine_start_position.z + ((((mine_layer % 2) * 2) + 2) * ((1 + mine_direction) % 2))
end

function miner:mine()
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
  end

  miner:go_to_mine_start()
  miner:go_down_the_mine()
  turtle.turn( mine_direction )
  miner:find_next_branch()
  -- branch_mine()
end

function miner:find_next_branch()
  local branch_index = 0

  while true do
    -- TODO: Force goto
    turtle.pathfind_to( miner:get_branch_entrance_pos( branch_index ), true )
    turtle.turn( LEFT )

    local s, d = turtle.inspect()

    if (not s or d.name ~= "minecraft:cobblestone") then return true end

    turtle.turn( RIGHT )
    branch_index = branch_index + 1

    if branch_index * 4 >= miner.branch_mine_quantity then return false end
  end

  return false
end

function miner:go_to_mine_start() turtle.pathfind_to( mine_start_position, false ) end

function miner:go_to_output_chest()
  local mine_output_position = vector.new(
    mine_start_position.x,
    mine_start_position.y,
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
  local mine_level_position = vector.new( mine_start_position.x, 6, mine_start_position.z )
  turtle.pathfind_to( mine_level_position, false )
end

function miner:drop_inventory()
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

-- Dig an infinite tunnel and place torch every 11 blocks
function miner:dig_tunnel()
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
end

return miner