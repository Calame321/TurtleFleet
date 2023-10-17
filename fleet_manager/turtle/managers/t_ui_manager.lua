local u = {}

local ONLY_LOG = false

-- Display all part of the ui.
function u.display()
  while true do
    term.clear()

    if ONLY_LOG then
      u.display_logs( 1 )
    else
      u.display_info()
      u.display_logs( 8 )
    end

    os.sleep( 0.05 )
  end
end

-- Display the current connected turtles.
function u.display_info()
  term.setCursorPos( 1, 1 )
  print( "Informations:" )
  print( " - Fuel: " .. turtle.getFuelLevel() .. "/" .. turtle.getFuelLimit() )
  if TTaskManager.current_task then
    print( " - Task: " .. TTaskManager.current_task.id .. "-" .. TTaskManager.current_task.type )
    local pos = TTaskManager.current_task.position
    print( "   - pos: " .. pos.x, pos.y, pos.z  )
  else
    print( " - Task: None" )
  end
  print( " - Host: " .. settings.get( "host_id" ) .. "-" .. settings.get( "host_name" ) )
  print( " - Connected: " .. tostring( TNetworkManager.connexion_confirmed ) )
  local facing_dir = turtle.data:facing()
  local facing_txt = turtle.direction_names[ facing_dir ] or "Unknown"
  print( " - pos: " .. turtle.data.x, turtle.data.y, turtle.data.z, "Facing:", facing_txt )
end

-- Display the logs with colors.
function u.display_logs( log_line )
  term.setCursorPos( 1, log_line )
  term.write( "Logs:" )
  local i = 1

  for v in Queue.iterator( TLogManager.logs ) do
    term.setCursorPos( 1, i + log_line )
    term.setTextColor( TLogManager.colors[ v.type ] )
    term.write( v.message )
    term.setTextColor( colors.white )
    i = i + 1
  end
end

return u