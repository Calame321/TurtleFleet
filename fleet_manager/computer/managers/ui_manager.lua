local u = {}

-- Display all part of the ui.
function u.display()
  while true do
    term.clear()

    u.display_turtles()
    u.display_tasks()
    u.display_logs()
    u.display_position()

    os.sleep( 0.05 )
  end
end

-- Display the current connected turtles.
function u.display_turtles()
  term.setCursorPos( 1, 1 )
  term.write( "Connected Turtles:" )

  -- If none.
  if #FleetManager.turtles == 0 then
    term.setCursorPos( 1, 2 )
    term.write( "None..." )
  end

  for k, v in pairs( FleetManager.turtles ) do
    term.setCursorPos( 1, k + 1 )
    -- Color red if the turtle is disconnected.
    if v.status == "disconnected" then
      term.setTextColor( colors.red )
    end
    
    -- Write the turtle info.
    term.write( v.id .. " - " .. v.name .. " - " .. v.status )
    -- Set the color back to white.
    term.setTextColor( colors.white )
  end
end

-- Display the current tasks.
function u.display_tasks()
  term.setCursorPos( 30, 1 )
  term.write( "Current Tasks:" )

  -- If none.
  if TaskRepository.has_any() == false then
    term.setCursorPos( 30, 2 )
    term.write( "None..." )
  end

  for k, v in pairs( TaskRepository.tasks ) do
    term.setCursorPos( 30, k + 1 )
    -- If the task is assigned, set the color to green.
    if v.status == "assigned" then
      term.setTextColor( colors.green )
    end
    -- Write the task.
    term.write( v.id .. " - " .. v.type )
    -- Set the color back to white.
    term.setTextColor( colors.white )
  end
end

-- Display the logs with colors.
function u.display_logs()
  term.setCursorPos( 1, 10 )
  term.write( "Logs:" )
  local i = 1

  for v in Queue.iterator( CLogManager.logs ) do
    term.setCursorPos( 1, i + 10 )
    term.setTextColor( CLogManager.colors[ v.type ] )
    term.write( v.message )
    term.setTextColor( colors.white )
    i = i + 1
  end
end

-- Display the current position
function u.display_position()
  local pos = settings.get( "position" )
  local chunk_pos = WorldManager.get_chunk_position( pos )
  term.setCursorPos( 1, 19 )
  term.write( "Position: " .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. "   Chunk: " .. chunk_pos.x .. "-" .. chunk_pos.z )
end

return u