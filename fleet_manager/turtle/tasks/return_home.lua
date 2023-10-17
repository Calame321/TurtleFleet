local o = {}

function o.execute( task )
  -- Has to move to the chunk position.
  TLogManager.log_info( "Going home." )
  -- Is the turtle in the chunk?
  local destination = ChunkManager.get_chunk_position( task.position )
  local turtle_chunk_pos = ChunkManager.get_chunk_position( turtle.data:position() )
  if turtle_chunk_pos.x ~= destination.x or turtle_chunk_pos.z ~= destination.z then
    local chunk_path = TNetworkManager.get_chunk_path( turtle_chunk_pos, destination )
    -- Pathfind in each chunk in the path.
    for _, v in ipairs( chunk_path ) do
      turtle_chunk_pos = ChunkManager.get_chunk_position( turtle.data:position() )
      local current_chunk = ChunkManager.get_chunk( turtle_chunk_pos )
      local destination_chunk = ChunkManager.get_chunk( v )
      local destination_center = destination_chunk:get_chunk_center_pos()
      local path = Pathfind.path_to_chunk_border( turtle.data:position(), destination_center, current_chunk )
      if path then turtle.move_path( path ) end
    end
  end
  
  local goal = vector.new( task.position.x, task.position.y, task.position.z )
  local path = TPathfind.a_star( turtle.data:position(), goal, ChunkManager.get_chunk( turtle_chunk_pos ) )
  TLogManager.log_debug( "Path home: " .. Pretty.render( Pretty.pretty( path ) ) )
  turtle.move_path( path )

  TLogManager.log_trace( "Home!" )
  task.completed = true
  TTaskManager.report_task_completion( task )
  ChunkManager.clear()
end

return o