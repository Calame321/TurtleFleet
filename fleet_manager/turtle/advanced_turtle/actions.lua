-----------
--- Dig ---
-----------

t.digs = {
  [ "f" ] = t.old_dig,
  [ "u" ] = t.digUp,
  [ "d" ] = t.digDown,
  [ "b" ] = t.digBack,
}

-- Dig the block behind the turtle.
function t.digBack()
  t.turn180()
  t.dig()
  t.turn180()
end

-- Mine until it can't mine again.
function t.dig_all( direction )
  local has_dug = t.digDir( direction )

  if not has_dug then
    return false
  end

  while has_dug do
    sleep( 0.05 )
    has_dug = t.digDir( direction )
  end

  return true
end

-- Override the default dig method.
-- Dig in a direction and check other stuff.
function t.dig( direction )
  local succes, err
  succes, err = t.digs[ direction:sub( 1, 1 ) ]()
  t.check_lava_source( direction )

  if t.is_inventory_full() then
    t.drop_in_storage()
  end

  return succes, err
end

------------
-- Detect --
------------

function t.detectBack()
  t.turn180()
  local success = t.detect()
  t.turn180()
  return success
end

function t.detect( direction )
  if direction:sub( 1, 1 ) == "f" then return t.old_detect()
  elseif direction:sub( 1, 1 ) == "u" then return t.detectUp()
  elseif direction:sub( 1, 1 ) == "d" then return t.detectDown()
  elseif direction:sub( 1, 1 ) == "b" then return t.detectBack()
  end
  error( "t.detect invalid direction!" )
end


-- Check if the block is the same as 'block_name'.
function t.is_block_name( direction, block_name )
  local s, b = t.inspect( direction )
  return s and b.name == block_name
end

-- Check if the block contains a string
function t.is_block_name_contains( direction, block_name )
  local s, b = t.inspect( direction )
  return s and string.find( b.name, block_name )
end

-- Check if the block has the tag.
function t.is_block_tag( dir, tag )
  local s, b = t.inspect( dir )

  -- If there is nothing, return.
  if not s then return false end

  -- If in minecraft 1.12, there is no "tags" table
  if type( b.tags ) == "table" then
    for k, v in pairs( b.tags ) do
      if string.find( k, tag ) ~= nil then
        return true
      end
    end
  end

  -- Else, try to find it in the name.
  return string.find( b.name, tag ) ~= nil
end

-------------
--- Place ---
-------------

-- place a block in front.
function t.place_forward( item_index )
  if item_index then t.select( item_index ) end
  return t.old_place()
end

-- place a block above.
function t.placeUp( item_index )
  if item_index then t.select( item_index ) end
  return t.old_placeUp()
end

-- place a block below.
function t.placeDown( item_index )
  if item_index then t.select( item_index ) end
  return t.old_placeDown()
end

-- Place a block to its right.
function t.placeRight( item_index )
  t.turnRight()
  local placed = t.place( item_index )
  t.turnLeft()
  return placed
end

-- Place a block to its left.
function t.placeLeft( item_index )
  t.turnLeft()
  local placed = t.place( item_index )
  t.turnRight()
  return placed
end

-- place a block based on a direction.
function t.place( direction )
  if direction:sub( 1, 1 ) == "f" then return t.place_forward()
  elseif direction:sub( 1, 1 ) == "u" then return t.placeUp()
  elseif direction:sub( 1, 1 ) == "d" then return t.placeDown()
  elseif direction:sub( 1, 1 ) == "l" then return t.placeLeft()
  elseif direction:sub( 1, 1 ) == "r" then return t.placeRight()
  end
  error( "t.place invalid direction" )
end

-- Wait until it can place a block in the direction.
function t.wait_place( direction )
  while not t.place( direction ) do
    print( "waiting 5 seconds before trying to place", direction, "again." )
    os.sleep( 5 )
  end
end

----------
-- Suck --
----------
function t.suck( direction )
  if direction == "forward" then return t.old_suck()
  elseif direction == "up" then return t.suckUp()
  elseif direction == "down" then return t.suckDown()
  end
  error( "t.suckDir invalid direction" )
end

function t.wait_suck( direction ) while not t.suckDir( direction ) do os.sleep( 1 ) end end

-- Return succes and if false, the name of the block
function t.move_inspect( direction )
  if t.move( direction ) then return true, nil end

  local s, d = t.inspectDir( direction )
  return false, d.name
end

function t.move_toward( destination )
  local distance = destination - t.position()

  if distance.x ~= 0 then
    if distance.x > 0 then
      t.turn( t.EAST )
    else
      t.turn( t.WEST )
    end
    return t.move_inspect( "forward" )
  end

  if distance.z ~= 0 then
    if distance.z > 0 then
      t.turn( t.SOUTH )
    else
      t.turn( t.NORTH )
    end
    return t.move_inspect( "forward" )
  end

  if distance.y ~= 0 then
    if distance.y > 0 then
      return t.move_inspect( "up" )
    else
      return t.move_inspect( "down" )
    end
  end

  return true
end

function t.dig_toward( destination )
  local distance = destination - t.position()

  if distance.x ~= 0 then
    if distance.x > 0 then
      t.turn( t.EAST )
    else
      t.turn( t.WEST )
    end
    return t.force_move( "forward" )
  end

  if distance.z ~= 0 then
    if distance.z > 0 then
      t.turn( t.SOUTH )
    else
      t.turn( t.NORTH )
    end
    return t.force_move( "forward" )
  end

  if distance.y ~= 0 then
    if distance.y > 0 then
      return t.force_move( "up" )
    else
      return t.force_move( "down" )
    end
  end

  return true
end

return t