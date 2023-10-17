-- The network manager object.
local n = {}

-- Ping id.
n.ping_id = 0

-- Result of the ping.
n.ping_result = false

n.craft_done = false

-- Open the model and set the host name so other computer can find it.
function n.start()
  -- Activate the modem.
  if peripheral.isPresent( "left" ) then rednet.open( "left" )
  elseif peripheral.isPresent( "right" ) then rednet.open( "right" )
  else error( "CNetworkManager.start(): Need a modem!" ) end
  rednet.host( settings.get( "protocol" ), settings.get( "host_name" ) )
  parallel.waitForAll( n.host_gps, CEventManager.check_events )
end

-- Host gps.
function n.host_gps()
  while true do
    local pos = settings.get( "position" )
    shell.run( "gps", "host", pos.x, pos.y, pos.z )
  end
end

--- Filter the message erceived by type.
---@param sender integer The id of the turtle that sent the message.
---@param message { type: string } The message received.
---@param protocol string The protocol used by the fleet.
function n.received_message( sender, message, protocol )
  if protocol == settings.get( "protocol" ) and type( message ) == "table" then
    -- A new turtle connects to the control center.
    if message.type == "turtle_connexion" then
      n.send_message( message.turtle.id, { type = "turtle_connexion" } )
      FleetManager.turtle_connected( message.turtle )
    -- A turtle completed his task.
    elseif message.type == "task_completed" then
      FleetManager.task_completed( message.turtle_id )
      CTaskManager.task_completed( message.task )
    -- A turtle returned a response for a ping.
    elseif message.type == "pong" then
      if message.id == n.ping_id then
        n.ping_result = true
        CLogManager.log_trace( "Pong received from " .. message.id )
      end
    -- Received a block position.
    elseif message.type == "block" then
      CLogManager.log_info( "Block received: " .. message.block .. " => " .. message.position.x .. ", " .. message.position.y .. ", " .. message.position.z )
      WorldManager.add_block( message.position, message.block )
    -- A turtle request a chunk.
    elseif message.type == "request_chunk" then
      CLogManager.log_info( "Turtle " .. sender .. " is requesting chunk: " .. message.chunk_pos.x .. "-" .. message.chunk_pos.z )
      local chunk = WorldManager.get_chunk( message.chunk_pos )
      CNetworkManager.send_message( sender, { type = "chunk", chunk = chunk } )
    -- A turtle request a path trough chunks.
    elseif message.type == "chunk_path" then
      local path = Pathfind.get_chunk_path( message.turtle_chunk_pos, message.destination_chunk_pos )
      n.send_message( sender, { type = "chunk_path", path = path } )
    -- Recived a craft result.
    elseif message.type == "craft" then
      n.craft_done = true
      CLogManager.log_info( "Received craft result: " .. tostring( message.result ) )
    elseif message.type == "turtle_inventory" then
      FleetManager.set_inventory( sender, message.slots )
    end
  else
    CLogManager.log_info( "Received message from " .. sender .. " with message " .. tostring( message ) )
  end
end

--- Function to send a message.
---@param destination integer The id of the turtle.
---@param message string|table
function n.send_message( destination, message )
    rednet.send( destination, message, settings.get( "protocol" ) )
end

--- Ping a turtle and wait a bit for an answer.
---@param id integer
---@return boolean # If the turtle responded.
function n.send_ping( id )
  CLogManager.log_trace( "Pinging id: " .. id )
  -- Keep the turtle id.
  n.ping_id = id
  -- Send the ping message.
  n.send_message( id, { type = "ping" } )
  -- Wait for the answer.
  sleep( 2 )
  -- Get the result.
  local result = n.ping_result
  -- Reset for the next one.
  n.ping_result = false
  -- return the result.
  return result
end

--- Send a craft request and wait for it to be done.
---@param destination integer
function n.send_craft_request( destination )
  n.send_message( destination, { type = "craft" } )
  while not n.craft_done do sleep( 0.1 ) end
  n.craft_done = false
end

return n