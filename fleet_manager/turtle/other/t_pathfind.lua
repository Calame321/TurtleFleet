local pathfind = {}

local grid_height_min = -64
local grid_height_max = 254
local AIR_HEIGHT_LIMIT = 2

--- Manathan distance between 2 vectors.
---@param node1 Node3D First node.
---@param node2 Node3D Second node.
---@return integer # The distance.
function pathfind.distance_to( node1, node2 )
  local d = node1.position - node2.position
  return math.abs( d.x ) + math.abs( d.y ) + math.abs( d.z )
end

--- All the node's neibourghs.
---@param node Node3D The center node.
---@return Node3D[] # The 6 neibourghs node.
function pathfind.get_neibourghs( node )
  return {
    Node3D.new( node.position + vector.new( -1,  0,  0 ) ),
    Node3D.new( node.position + vector.new(  1,  0,  0 ) ),
    Node3D.new( node.position + vector.new(  0, -1,  0 ) ),
    Node3D.new( node.position + vector.new(  0,  1,  0 ) ),
    Node3D.new( node.position + vector.new(  0,  0, -1 ) ),
    Node3D.new( node.position + vector.new(  0,  0,  1 ) )
  }
end

--- A* finds a path from start to goal.
---@param start vector
---@param goal vector
---@param chunk Chunk
---@return vector[] | nil
function pathfind.a_star( start, goal, chunk )
  TLogManager.log_debug( "A*| start: " .. start:tostring() .. ", " .. goal.x .. "," .. goal.y .. "," .. goal.z )
  local start_node = Node3D.new( start )
  local goal_node = Node3D.new( goal )
  -- Array of cells opened to check next.
  local open_set = { start_node }
  -- Array of cells that have been checked.
  local closed_set = {}
  open_set[ 1 ].f = pathfind.distance_to( start_node, goal_node )

  -- Check if a cell is valid. ( Within bounds and not a block. )
  local function is_valid_cell( pos, chunk )
    local min, max = chunk:get_range()
    if pos.x >= min.x and pos.x <= max.x and pos.y >= grid_height_min and pos.y <= grid_height_max and pos.z >= min.z and pos.z <= max.z then
      return chunk:get_block( pos ) == "air"
    end
    return false
  end

  local count = 0
  local count2 = 0

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
          table.insert( path, 1, temp.position )
          temp = temp.parent
      end
      TLogManager.log_trace( "A*, Path length: " .. #path )
      return path
    end

    -- All neibourghs position.
    local neighbors = pathfind.get_neibourghs( current )

    -- check the neibourghs.
    for _, neighbor in ipairs( neighbors ) do
      if not closed_set[ neighbor:key() ] and is_valid_cell( neighbor.position, chunk ) then
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

    -- Prevent "Too long without yielding"
    if count == 1000 then
      sleep( 0 )
      count = 0
      count2 = count2 + 1
    end
    count = count + 1
  end

  -- Open set is empty but goal was never reached.
  TLogManager.log_error( "No path found!" )
  return nil
end

-- A* finds a path from start to goal.
function pathfind.path_to_chunk_border( start, goal, chunk )
  TLogManager.log_debug( "A*| start: " .. start:tostring() .. ", " .. goal:tostring() )
  local start_node = Node3D.new( start )
  local goal_node = Node3D.new( goal )
  -- Array of cells opened to check next.
  local open_set = { start_node }
  -- Array of cells that have been checked.
  local closed_set = {}
  open_set[ 1 ].f = pathfind.distance_to( start_node, goal_node )

  -- Check if a cell is valid. ( Within bounds and not a block. )
  local function is_valid_cell( pos, chunk )
    local min, max = chunk:get_range()
    if pos.x >= min.x and pos.x <= max.x and pos.y >= grid_height_min and pos.y <= grid_height_max and pos.z >= min.z and pos.z <= max.z then
      return chunk:get_block( pos ) == "air"
    end
    return false
  end

  local function is_valid_border_block( current, goal, chunk )
    -- If the position is not a border.
    local local_pos = vector.new( current.position.x % 16, current.position.y, current.position.z % 16 )
    if local_pos.x > 0 and local_pos.x < 15 and local_pos.z > 0 and local_pos.z < 15 then return false end
    -- Get the direction of the goal.
    local current_chunk_pos = ChunkManager.get_chunk_position( current.position )
    local destination_chunk_pos = ChunkManager.get_chunk_position( goal.position )
    local x_diff = destination_chunk_pos.x - current_chunk_pos.x
    local z_diff = destination_chunk_pos.z - current_chunk_pos.z
    -- If it's not the correct border.
    if x_diff ==  1 and local_pos.x < 15 then return false end
    if x_diff == -1 and local_pos.x >  0 then return false end
    if z_diff ==  1 and local_pos.z < 15 then return false end
    if z_diff == -1 and local_pos.z >  0 then return false end
    -- If the block is is air.
    if chunk:get_block( current.position ) ~= "air" then return end
    -- If the first block in the next chunk is air.
    local next_pos = vector.new( current.position.x + x_diff, current.position.y, current.position.z + z_diff )
    local next_block = ChunkManager.get_block( next_pos )
    if next_block ~= "air" then return false end
    -- Everithing is ok!
    return Node3D.new( next_pos )
  end

  local count = 0
  local count2 = 0

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
    -- If it's a block of air next to a chunk border in the correct direction.
    local next_node = is_valid_border_block( current, goal_node, chunk )
    if next_node then
      next_node.parent = current
      current = next_node
      local path = {}
      local temp = current
      while temp do
        if temp.parent == nil then break end
          table.insert( path, 1, temp.position )
          temp = temp.parent
      end
      TLogManager.log_trace( "A*, Path length: " .. #path )
      return path
    end
    -- All neibourghs position.
    local neighbors = pathfind.get_neibourghs( current )
    -- check the neibourghs.
    for _, neighbor in ipairs( neighbors ) do
      if not closed_set[ neighbor:key() ] and is_valid_cell( neighbor.position, chunk ) then
        local tentative_g = current.g + pathfind.distance_to( current, neighbor )
        local neighbor_in_open_set = false
        -- Look for the neibourgh in the open set.
        for _, open_node in ipairs( open_set ) do
          if neighbor == open_node then
            neighbor_in_open_set = true
            break
          end
        end
        -- If he's not in the open set or he has a better score.
        if not neighbor_in_open_set or tentative_g < neighbor.g then
          neighbor.h = pathfind.distance_to( neighbor, goal_node )
          neighbor.f = tentative_g + neighbor.h
          neighbor.parent = current
          -- Add it to the open set.
          if not neighbor_in_open_set then
            table.insert( open_set, neighbor )
          end
        end
      end
    end

    -- Prevent "Too long without yielding"
    if count == 1000 then
      sleep( 0 )
      count = 0
      count2 = count2 + 1
    end
    count = count + 1
  end

  -- Open set is empty but goal was never reached.
  TLogManager.log_error( "No path found!" )
  return nil
end

-- Find the closest unexplored node using BFS
-- start: The starting position vector.
-- chunk: The chunk data.
function pathfind.find_closest_unexplored( start, chunk )
  -- Keep track of visited nodes.
  local visited = {}
  -- Queue for BFS.
  local queue = {}

  -- Check if a node is explored.
  local function is_explored( node, c )
    return c:get_block( node.position ) ~= nil
  end

  -- Check if a cell is valid. ( Within bounds. )
  local function is_valid_cell( pos, chunk )
    local min, max = chunk:get_range()
    if pos.x >= min.x and pos.x <= max.x and pos.y >= grid_height_min and pos.y <= grid_height_max and pos.z >= min.z and pos.z <= max.z then
      -- If we know the highest block position and the highest point to explore is reached.
      if chunk.highest_block_height > -64 and pos.y > chunk.highest_block_height + AIR_HEIGHT_LIMIT then
        return false
      end

      return ( chunk:get_block( pos ) or "air" ) == "air"
    end
    return false
  end

  -- Initialize the queue with the starting position
  local count = 0
  local count2 = 0
  table.insert( queue, Node3D.new( start ) )

  while #queue > 0 do
    local current = table.remove( queue, 1 )

    -- Check if the current node is unexplored
    if not is_explored( current, chunk ) then
      -- Found an unexplored node.
      TLogManager.log_trace( "Unexplored found: " .. current.parent.position:tostring() )
      return current.parent.position
    end

    -- Mark the current node as visited.
    visited[ current:key() ] = true

    -- Explore neighboring nodes.
    local neighbors = pathfind.get_neibourghs( current )

    for _, neighbor in pairs( neighbors ) do
      if not visited[ neighbor:key() ] and is_valid_cell( neighbor.position, chunk ) then
        -- Look for the neibourgh in the queue.
        local neighbor_is_in_queue = false
        for _, queued_node in ipairs( queue ) do
          if neighbor == queued_node then
            neighbor_is_in_queue = true
            break
          end
        end
        -- Add the neibourgh to be queue.
        if not neighbor_is_in_queue then
          neighbor.parent = current
          table.insert( queue, neighbor )
        end
      end
    end

    -- Prevent "Too long without yielding"
    if count == 500 then
      sleep( 0 )
      count = 0
      print( "Unexplored yelding: " .. count2 )
      count2 = count2 + 1
    end
    count = count + 1
  end

  -- No unexplored nodes found.
  TLogManager.log_debug( "No unexplored nodes found." )
  return nil
end

return pathfind