local o = {}

function o.get_direction( vector )
  if vector.x == -1 then return turtle.WEST end
  if vector.x ==  1 then return turtle.EAST end
  if vector.y == -1 then return turtle.DOWN end
  if vector.y ==  1 then return turtle.UP end
  if vector.z == -1 then return turtle.NORTH end
  if vector.z ==  1 then return turtle.SOUTH end
  return nil
end

--- Used to know if a position is valid for the + pattern.
---@param x integer
---@param y integer
---@return boolean # If it's valid.
function o.is_valid_patern( x, y )
  x, y = x % 5, y % 5
  return ( ( x == 0 and y == 0 )
        or ( x == 2 and y == 1 )
        or ( x == 4 and y == 2 )
        or ( x == 1 and y == 3 )
        or ( x == 3 and y == 4 ) )
end

return o