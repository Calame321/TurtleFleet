local t = turtle

---------------
--- Dig Out ---
---------------
local do_width_remaining = 0
local do_row_remaining = 0
local do_width_start = 0
local digout_row_done = 0

function t.dig_out( depth, width )
  t.force_move( t.FORWARD )
  t.turnRight()
  do_width_remaining = width
  do_width_start = width
  do_row_remaining = depth
  digout_row_done = 0
  t.dig_out_loop()
end

function t.dig_out_loop()
  while do_row_remaining ~= 0 do
    t.dig_out_row()
    if do_row_remaining ~= 1 then
      t.dig_out_change_row()
    else
      do_row_remaining = 0
    end
  end

  -- Return start.
  if digout_row_done % 2 == 0 then
    t.turn180()
    for _ = 1, do_width_start - 1 do
      t.wait_move( t.FORWARD )
    end
  end

  t.turn( t.RIGHT )
  t.drop_in_storage()
end

function t.dig_out_row()
  while do_width_remaining ~= 0 do
    t.select( 1 )

    if not t.dig_all( t.UP ) then
      local s, d = t.inspect( t.UP )
      if s and ( d.name == "minecraft:lava" or d.name == "minecraft:water" ) and d.state.level == 0 then
        t.force_move( t.UP )
        t.force_move( t.DOWN )
      end
    end

    if not t.dig_all( t.DOWN ) then
      local s, d = t.inspect( t.DOWN )
      if s and ( d.name == "minecraft:lava" or d.name == "minecraft:water" ) and d.state.level == 0 then
        t.force_move( t.DOWN )
        t.force_move( t.UP )
      end
    end

    if do_width_remaining ~= 1 then
      t.force_move( t.FORWARD )
    end

    do_width_remaining = do_width_remaining - 1
  end
end

function t.dig_out_change_row()
  if digout_row_done % 2 == 0 then
    t.turn( t.LEFT )
  else
    t.turn( t.RIGHT)
  end

  t.force_move( t.FORWARD )

  if  digout_row_done % 2 == 0 then
    t.turn( t.LEFT )
  else
    t.turn( t.RIGHT)
  end

  do_width_remaining = do_width_start
  do_row_remaining = do_row_remaining - 1
  digout_row_done = digout_row_done + 1
end

---------------------
--- Branch Mining ---
---------------------

t.branch_mine_quantity = 20
t.branch_mine_length = 20

--- Empty the inventory in the starting chest.
function t.empty_inventory()
  for i = 1, 16 do
    -- If it's a storage slot and a drop storage, drop it's content in the chest
    if t.is_storage_slot( i ) then
      if t.get_storage_type( i ) == t.DROP_STORAGE then
        -- place the storage above
        t.dig_all( "up" )
        t.select( i )
        t.placeUp()

        -- get all the item in the storage above and drop them in the chest
        while t.suckUp() do
          if not t.drop() then
            print( "Please, make some place in the chest !!" )
            while not t.drop() do os.sleep( 5 ) end
          end
        end

        -- Pick up the storage
        t.digUp()
      end
    else
      local item = t.getItemDetail( i )

      if item and not t.is_valid_fuel( item.name ) and item.name ~= "minecraft:bucket" then
        t.select( i )

        if not t.drop() then
          print( "Please, make some place in the chest !!" )
          while not t.drop() do os.sleep( 5 ) end
        end
      end
    end
  end
end

--- Check if the block is a ore block.
---@param direction any
---@return boolean
function t.check_ore( direction )
  if t.is_block_tag( direction, "forge:ores" ) or t.is_block_tag( direction, "_ore" ) then
    local _, data = t.inspect( direction )
    local ore_name = data.name

    for b = 1, #t.forbidden_block do
      if ore_name == t.forbidden_block[ b ] then
        return false
      end
    end

    t.force_move( direction )
    t.vein_mine( direction, ore_name )
  end

  return true
end

function t.vein_mine( from, block )
  if t.is_inventory_full() then t.drop_in_storage() end

  -- up
  if t.is_block_name( t.UP, block ) then
    t.force_move( t.UP )
    t.vein_mine( t.UP, block )
  end

  -- forward
  if t.is_block_name( t.FORWARD, block ) then
    t.force_move( t.FORWARD )
    vein_mine( t.FORWARD, block )
  end

  -- down
  if t.is_block_name( t.DOWN, block ) then
    t.force_move( t.DOWN )
    vein_mine( t.DOWN, block )
  end

  -- left
  t.turn( t.LEFT )

  if t.is_block_name( t.FORWARD, block ) then
    t.force_move( t.FORWARD )
    vein_mine( t.FORWARD, block )
  end

  -- right
  t.turn180()

  if t.is_block_name( t.FORWARD, block ) then
    t.force_move( t.FORWARD )
    vein_mine( t.FORWARD, block )
  end

  t.turn( t.LEFT )
  t.reverse( from )
end


--- Mine one branch.
---@return boolean
function t.mine_branch()
  local found_forbidden_ore = false
  local depth = 0

  for _ = 1, t.branch_mine_length do
    depth = depth + 1
    if not t.check_ore( t.FORWARD ) then found_forbidden_ore = true end
    if not found_forbidden_ore then t.force_move( t.FORWARD ) end
    if t.is_inventory_full() then t.drop_in_storage() end
    if not t.check_ore( t.UP ) then found_forbidden_ore = true end
    if not t.check_ore( t.DOWN ) then found_forbidden_ore = true end
    t.turnLeft()
    if not t.check_ore( t.FORWARD ) then found_forbidden_ore = true end
    t.turn180()
    if not t.check_ore( t.FORWARD ) then found_forbidden_ore = true end
    t.turnLeft()

    if found_forbidden_ore then
      print( "FOUND DO_NOT_MINE ORE !!!!" )
      break
    end
  end

  for _ = 0, depth - 1 do
    t.force_move( t.BACK )
    if found_forbidden_ore then t.digDown() end
  end

  return found_forbidden_ore
end

--- Mine the number of branches 
---@param side any
function t.branch_mine( side )
  local branch_index = 0

  for _ = 1, t.branch_mine_quantity do
    t.turn180()

    for _ = 1, ( branch_index * 4 ) do t.force_forward() end

    if side == "left" then
      t.turnRight()
    else
      t.turnLeft()
    end

    t.mine_branch()

    if side == "left" then
      t.turnRight()
    else
      t.turnLeft()
    end

    for _ = 1, ( branch_index * 4 ) do t.force_forward() end

    t.empty_inventory()
    branch_index = branch_index + 1
  end
end

--- Start branch mining with specific length.
---@param side "left"|"right" The side the turtle will mine the branches.
---@param branch_nb integer Number of branches.
---@param branch_length integer Length of each branch.
function t.start_branch_mining( side, branch_nb, branch_length )
  t.branch_mine_quantity = branch_nb or t.branch_mine_quantity
  t.branch_mine_length = branch_length or t.branch_mine_length
  t.branch_mine( side )
end


return t