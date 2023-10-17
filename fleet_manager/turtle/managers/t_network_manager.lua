-- The network manager object.
local n = {}

n.chunk_path = nil
n.received_chunk = false
n.received_chunk_path = false
n.connexion_confirmed = false

-- Open the modem, get the host id and tell the command center this turtle is ready for a task.
function n.start()
  term.setCursorPos( 5, 5 )
  term.write( "Connecting to the network..." )
  -- Activate the modem.
  local modem_side = turtle.get_equipement_side( "computercraft:wireless_modem_normal" ) or turtle.get_equipement_side( "computercraft:wireless_modem_advanced" )
  if not modem_side then n.connexion_confirmed = false; return end
  rednet.open( modem_side )
  -- Connect to the command center.
  n.connect_server()
  -- Wait for a confirmation.
  local timer = 0
  while n.connexion_confirmed == false do
    sleep( 0 )
    timer = timer + 1
    if timer >= 30 then break end
    term.setCursorPos( 19, 7 )
    term.write( string.char( math.random(255) ) .. string.char( math.random(255) ) )
    n.connect_server()
  end
  -- If the connexion failed.
  if n.connexion_confirmed == false then
    TLogManager.log_error( "Did not receive a valid connection from the command center." )
    return
  end
  -- Get the turtle's position.
  local x1, y1, z1 = TNetworkManager.get_position()
  -- It's bad if the saved position is not the same as the gps one.
  TLogManager.log_debug( vector.new( x1, y1, z1 ):tostring() .. " - " .. vector.new( turtle.data.x, turtle.data.y, turtle.data.z ):tostring() )
  if turtle.data.x ~= x1 or turtle.data.y ~= y1 or turtle.data.z ~= z1 then turtle.data.position_acuracy = "bad" end
  turtle.data.x, turtle.data.y, turtle.data.z = x1, y1, z1
  -- Calculate the facing direction if the position acuracy is bad.
  if turtle.data.position_acuracy == "bad" then
    if turtle.forward() then
      local x, _, z = TNetworkManager.get_position()
      turtle.data.dx = x - x1
      turtle.data.dz = z - z1
      TLogManager.log_debug( "turtle.data.dx: " .. turtle.data.dx .. " turtle.data.dz: " .. turtle.data.dz )
      TSettingsManager.save_facing()
      turtle.back()
    elseif turtle.back() then
      local x, _, z = TNetworkManager.get_position()
      turtle.data.dx = x1 - x
      turtle.data.dz = z1 - z
      TSettingsManager.save_facing()
      turtle.forward()
    else
      error( "TNetworkManager: Calculate the facing direction. Not enough space." )
    end
    turtle.data.position_acuracy = "perfect"
  end
  TLogManager.log_debug( "turtle.data.position_acuracy: " .. turtle.data.position_acuracy )
  term.clear()
end

--- Try to connect to the command center
function n.connect_server()
  -- Get the host id.
  local host_id = n.get_host_id()
  -- Send message.
  turtle.data:set_inventory()
  rednet.send( host_id, { type = "turtle_connexion", turtle = turtle.data }, settings.get( "protocol" ) )
  local _, _, message, protocol = os.pullEvent( "rednet_message" )
  n.connexion_confirmed = message.type == "turtle_connexion" and protocol == settings.get( "protocol" )
end

-- TODO: Add a function on a timer to test connexion with command center.

-- Get the host id from the settings or the network.
function n.get_host_id()
  local host_id = settings.get( "host_id" )
  -- If the host id is not set, check the network to find it.
  if host_id == -1 then
    host_id = rednet.lookup( settings.get( "protocol" ), settings.get( "host_name" ) )
    settings.set( "host_id", host_id )
    settings.save( ".settings" )
    TLogManager.log_trace( "The host is: " .. host_id .. "-" .. settings.get( "host_name" ) )
  end

  return host_id
end

--- Function to send a message to the command center.
---@param message { type: string }
function n.send_message( message )
    rednet.send( n.get_host_id(), message, settings.get( "protocol" ) )
end

--- Filter the message erceived by type.
---@param sender integer The id of the computer that sent the message.
---@param message { type: string } The message received.
---@param protocol string The protocol used by the fleet.
function n.received_message( sender, message, protocol )
  -- If it's a valid protocol and the message is a table.
  if protocol == settings.get( "protocol" ) and type( message ) == "table" then
    -- Confirmation that the command center received the 'turtle_connexion' message.
    if message.type == "turtle_connexion" then
      n.connexion_confirmed = true
      TLogManager.log_info( "Received turtle_connexion answer!" )
    elseif message.type == "task" then
      TTaskManager.set_new_task( message.task )
    -- The command center ping to check if still alive.
    elseif message.type == "ping" then
      n.send_message( { type = "pong", id = os.computerID() } )
    -- The command center sent chunk data.
    elseif message.type == "chunk" then
      TLogManager.log_info( "Received chunk: " .. message.chunk.position.x .. "-" .. message.chunk.position.z )
      ChunkManager.set_chunk( message.chunk )
      n.received_chunk = true
    -- Receive a chunk path.
    elseif message.type == "chunk_path" then
      n.chunk_path = message.path
      n.received_chunk_path = true
    -- Received craft request.
    elseif message.type == "craft" then
      local result = turtle.craft()
      n.send_message( { type = "craft", result = result } )
      TLogManager.log_info( "Crafted something!" )
    -- Unknown type.
    else
      TLogManager.log_info( "Received an unknown message type: " .. Pretty.render( Pretty.pretty( message ) ) )
    end
  else
    TLogManager.log_info( "Received message from " .. sender .. " and protocol " .. protocol .. " with message " .. Pretty.render( Pretty.pretty( message ) ) )
  end
end

--- Get the position from a GPS sattelite.
---@return integer|nil x
---@return integer|nil y
---@return integer|nil z
function n.get_position()
  local x, y, z = gps.locate()
  if x then
    turtle.has_valid_position = true
    TLogManager.log_info( "GPS location from " .. debug.getinfo( 2 ).name .. ": " .. x .. "," .. y .. "," .. z )
    return x, y, z
  else
    sleep( 2 )
    x, y, z = gps.locate()
    if x then
      turtle.has_valid_position = true
      return x, y, z
    end
  end
  TLogManager.log_error( "Can't get GPS location. I might be lost..." )
  turtle.has_valid_position = false
  return nil, nil, nil
end

--- Get a path trough chunk instead of blocks so it's faster.
---@param start { x: integer, z: integer }
---@param goal { x: integer, z: integer }
---@return { x: integer, z: integer }[]
function n.get_chunk_path( start, goal )
  n.send_message( { type = "chunk_path", turtle_chunk_pos = start, destination_chunk_pos = goal, sender = os.computerID() } )
  while not n.received_chunk_path do sleep( 1 ) end
  n.received_chunk_path = false
  if n.chunk_path == nil then error( "Chunk_path is null." ) end
  return n.chunk_path
end

--- Send the turtle's inventory content so the command center.
function n.send_inventory()
  n.send_message( { type = "turtle_inventory", slots = turtle.data.slots } )
end

return n