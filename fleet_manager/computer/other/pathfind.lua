local pathfind = {}

-- Manathan distance between 2 vectors.
function pathfind.distance_to( node1, node2 )
  return math.abs( node1.x - node2.x ) + math.abs( node1.z - node2.z )
end

--- All the node's neibourghs.
---@param node Node2D
---@return Node2D[]
function pathfind.get_neibourghs( node )
  return {
    Node2D.new( node.x - 1, node.z ),
    Node2D.new( node.x + 1, node.z ),
    Node2D.new( node.x, node.z - 1 ),
    Node2D.new( node.x, node.z + 1 )
  }
end

-- A* finds a path from start to goal.
function pathfind.get_chunk_path( start, goal )
  CLogManager.log_debug( "A*| start: " .. start.x .. "-" .. start.z .. ", " .. goal.x .. "-" .. goal.z )
  local start_node = Node2D.new( start.x, start.z )
  local goal_node = Node2D.new( goal.x, goal.z )
  -- Array of cells opened to check next.
  local open_set = { start_node }
  -- Array of cells that have been checked.
  local closed_set = {}
  open_set[ 1 ].f = pathfind.distance_to( start_node, goal_node )

  -- Check if a cell is valid. ( Within bounds and not a block. )
  local function is_valid_chunk( node, goal_pos )
    if node == goal_pos then return true end
    local chunk = WorldManager.get_chunk( { x = node.x, z = node.z } )
    return chunk:is_covered()
  end

  while #open_set > 0 do
    local current = open_set[ 1 ]
    local current_index = 1

    -- Find the node with the lowest f score.
    for i, node in ipairs( open_set ) do
      if node.f < current.f then
        current = node
        current_index = i
      end
    end

    -- Switch the current node to the closed set.
    table.remove( open_set, current_index )
    closed_set[ current:key() ] = true

    -- path found? rebuild and return it.
    if current == goal_node then
      local path = {}
      local temp = current
      while temp do
        if temp.parent == nil then break end
          table.insert( path, 1, { x = temp.x, z = temp.z } )
          temp = temp.parent
      end
      CLogManager.log_trace( "A*, Path length: " .. #path )
      return path
    end

    -- All neibourghs position.
    local neighbors = pathfind.get_neibourghs( current )

    -- check the neibourghs.
    for _, neighbor in ipairs( neighbors ) do
      if not closed_set[ neighbor:key() ] and is_valid_chunk( neighbor, goal_node ) then
        local tentative_g = current.g + pathfind.distance_to( current, neighbor )
        local neighbor_in_open_set = false

        -- Look for the neibourgh in the open set.
        for _, open_node in ipairs( open_set ) do
          if neighbor == open_node then
            neighbor_in_open_set = true
            break
          end
        end

        if not neighbor_in_open_set or tentative_g < neighbor.g then
          neighbor.h = pathfind.distance_to( neighbor, goal_node )
          neighbor.f = tentative_g + neighbor.h
          neighbor.parent = current

          if not neighbor_in_open_set then
            table.insert( open_set, neighbor )
          end
        end
      end
    end
  end

  -- Open set is empty but goal was never reached.
  CLogManager.log_error( "No path found!" )
  return nil
end

return pathfind