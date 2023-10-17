
function t.wait_forward()
  while not t.forward() do
    os.sleep( 0.5 )
  end
end

function t.force_forward( block_to_break )
  t.force_move( "forward", block_to_break )
end

function t.wait_down()
  while not t.down() do os.sleep( 0.5 )
  end
end

function t.force_down( block_to_break )
  t.force_move( "down", block_to_break )
end

function t.wait_back()
  while not t.back() do
    os.sleep( 0.5 )
  end
end

function t.force_back( block_to_break )
  t.force_move( "back", block_to_break )
end

function t.wait_up()
  while not t.up() do
    os.sleep( 0.5 )
  end
end

function t.force_up( block_to_break )
  t.force_move( "up", block_to_break )
end

-- Reverse --
function t.reverse( direction )
  return t.move( t.reverseDir( direction ) )
end

function t.force_reverse( direction )
  t.force_move( t.reverseDir( direction ) )
end

-- Move --
function t.wait_move( direction )
  while not t.move( direction ) do
    print( "Waiting 5 seconds before trying to move", direction, "again." )
    os.sleep( 5 )
  end
end

-- Move in a direction, if can't, break any blocks.
function t.force_move( direction, block_to_break )
  if direction ~= "back" then
    for k, v in pairs( t.forbidden_block ) do
      if t.is_block_name( direction, v ) then
        print( "I am scared of this", v, ". Can you remove it please?" )

        while t.is_block_name( direction, v ) do
          os.sleep( 5 )
        end
      end
    end

    t.check_lava_source( direction )
  end

  while not t.move( direction ) do
    local s, d = t.inspectDir( direction )
    if s and string.find( d.name, "turtle" ) then
      os.sleep( 0.5 )
    elseif not block_to_break or t.is_block_name( direction, block_to_break ) then
      t.digDir( direction )
    end
  end
end

-- Follow a path as a string "neenww", destroying any block in the way.
function t.force_move_path( path )
  for i = 1, #path do
    local dir = path:sub( i, i )

    if dir == "d" then t.force_move( "down" )
    elseif dir == "u" then t.force_move( "up" )
    elseif dir == "f" then t.force_move( "forward" )
    elseif dir == "b" then t.force_move( "back" )
    elseif dir == "l" then t.turnLeft()
    elseif dir == "r" then t.turnRight()
    elseif dir == "n" then t.turn( t.NORTH )
    elseif dir == "s" then t.turn( t.SOUTH )
    elseif dir == "e" then t.turn( t.EAST )
    elseif dir == "w" then t.turn( t.WEST )
    end
  end
end
