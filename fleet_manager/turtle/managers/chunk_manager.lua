local o = {}

o.chunks = {}

--- Get a chunk from it's position.
--- If the turtle dosen't have it, it will ask the commande center for it.
---@param chunk_pos { x: integer, z: integer } The chunk position.
---@return Chunk # The chunk at the position.
function o.get_chunk( chunk_pos )
  o.chunks[ chunk_pos.x ] = o.chunks[ chunk_pos.x ] or {}
  o.chunks[ chunk_pos.x ][ chunk_pos.z ] = o.chunks[ chunk_pos.x ][ chunk_pos.z ]
  -- Ask the chunk data from the command center.
  if o.chunks[ chunk_pos.x ][ chunk_pos.z ] == nil then
    TLogManager.log_info( "requested chunk: " .. chunk_pos.x .. "-" .. chunk_pos.z )
    TNetworkManager.send_message( { type = "request_chunk", chunk_pos = chunk_pos, sender = os.computerID() } )
    -- Wait for the chunk.
    while not TNetworkManager.received_chunk do sleep( 0.2 ) end
    TNetworkManager.received_chunk = false
    if o.chunks[ chunk_pos.x ][ chunk_pos.z ] == nil then error("chunk is nil") end
  end

  return o.chunks[ chunk_pos.x ][ chunk_pos.z ]
end

--- Set the whole chunk.
---@param chunk Chunk
function o.set_chunk( chunk )
  local fresh_chunk = Chunk.refresh( chunk )
  o.chunks[ fresh_chunk.position.x ] = o.chunks[ fresh_chunk.position.x ] or {}
  o.chunks[ fresh_chunk.position.x ][ fresh_chunk.position.z ] = fresh_chunk
end

--- Add a bock to the data.
---@param position vector
---@param block string
function o.set_block( position, block )
  local chunk_pos = o.get_chunk_position( position )
  local chunk = o.get_chunk( chunk_pos )
  chunk:set_block( position, block )
end

--- Get a block at a position.
---@param position vector
---@return string|nil
function o.get_block( position )
  local chunk_pos = o.get_chunk_position( position )
  local chunk = o.get_chunk( chunk_pos )
  if chunk == nil then return nil end
  return chunk:get_block( position )
end

--- Remove all chunk from memory.
function o.clear()
  o.chunks = {}
end

--- Change a world position to a chunk position.
---@param position vector
---@return { x: integer, z: integer }
function o.get_chunk_position( position )
  -- Shift the bit to get the x coord of the chunk.
  local x = bit.brshift( math.abs( position.x ), 4 )
  -- We substract 1 if the position is negative.
  if position.x < 0 then x = x - 1 end
  -- Shift the bit to get the z coord of the chunk.
  local z = bit.brshift( math.abs( position.z ), 4 )
  -- We substract 1 if the position is negative.
  if position.z < 0 then z = z - 1 end
  return { x = x, z = z }
end

return o