local o = {}

-- All the node's neibourghs.
function o.get_neibourgh_directions()
  return {
    vector.new( -1,  0,  0 ),
    vector.new(  1,  0,  0 ),
    vector.new(  0, -1,  0 ),
    vector.new(  0,  1,  0 ),
    vector.new(  0,  0, -1 ),
    vector.new(  0,  0,  1 )
  }
end

-- Manathan distance between 2 vectors.
function o.distance_to( pos1, pos2 )
  local d = pos1 - pos2
  return math.abs( d.x ) + math.abs( d.y ) + math.abs( d.z )
end

function o.execute( task )
  -- Has to move to the chunk position.
  local destination = task.position
  TLogManager.log_info( "Scouting chunk " .. destination.x .. "-" .. destination.z )
  -- Is the turtle in the chunk?
  local turtle_chunk_pos = ChunkManager.get_chunk_position( turtle.position() )
  if turtle_chunk_pos.x ~= destination.x or turtle_chunk_pos.z ~= destination.z then
    local chunk_path = TNetworkManager.get_chunk_path( turtle_chunk_pos, destination )
    -- Pathfind in each chunk in the path.
    for _, v in ipairs( chunk_path ) do
      turtle_chunk_pos = ChunkManager.get_chunk_position( turtle.position() )
      local current_chunk = ChunkManager.get_chunk( turtle_chunk_pos )
      local destination_chunk = ChunkManager.get_chunk( v )
      local destination_center = destination_chunk:get_chunk_center_pos()
      local path = TPathfind.path_to_chunk_border( turtle.position(), destination_center, current_chunk )
      if path then turtle.move_path( path ) end
    end
  end

  ChunkManager.set_block( turtle.position(), "air" )
  o.scan_blocks()
  local chunk = ChunkManager.get_chunk( task.position )

  while true do
    -- Find the closest unexplored square.
    TLogManager.log_trace( "Scout: Find unexplored" )
    local next = Pathfind.find_closest_unexplored( turtle.position(), chunk )
    -- Stop if there is no unexplored position left.
    if next == nil then break end
    -- Get the path to it.
    TLogManager.log_trace( "Scout: Find path" )
    local path = Pathfind.a_star( turtle.position(), next, chunk )
    -- Follow the path.
    TLogManager.log_trace( "Scout: Follow path" )
    turtle.move_path( path )
    -- Scan the blocks.
    TLogManager.log_trace( "Scout: scan blocks" )
    o.scan_blocks()
  end

  TLogManager.log_trace( "Scout: Done!" )
  task.completed = true
  TTaskManager.report_task_completion( task )
  ChunkManager.clear()
end

-- Scan the valid surronding blocks.
function o.scan_blocks()
  local directions = o.get_neibourgh_directions()
  for _, vector in pairs( directions ) do
    local dir = Utils.get_direction( vector )
    local pos = turtle.position() + vector
    -- Scan the unexplored block.
    if ChunkManager.get_block( pos ) == nil then
      local s, b = turtle.inspect( dir )
      if not s then b = { name = "air" } end
      ChunkManager.set_block( pos, b.name )
      TNetworkManager.send_message( { type = "block", position = pos, block = b.name } )
    end
  end
end

return o