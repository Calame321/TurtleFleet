local o = {}

o.SAVE_FOLDER = "data/chunks/"

o.chunks = {}
o.chunk_count = 0
o.first_chunk_covered = false

--- Get a chunk from it's position.
---@param chunk_pos { x: integer, z: integer } The chunk position.
---@return Chunk # The chunk at the position.
function o.get_chunk( chunk_pos )
  o.chunks[ chunk_pos.x ] = o.chunks[ chunk_pos.x ] or {}
  o.chunks[ chunk_pos.x ][ chunk_pos.z ] = o.chunks[ chunk_pos.x ][ chunk_pos.z ] or Chunk.new( chunk_pos )
  return o.chunks[ chunk_pos.x ][ chunk_pos.z ]
end

--- Set the whole chunk, block by block.
---@param chunk Chunk
function o.set_chunk( chunk )
  for k1, v1 in pairs( chunk.blocks ) do
    for k2, v2 in pairs( v1 ) do
      for k3, v3 in pairs( v2 ) do
        o.set_block( vector.new( k1, k2, k3 ), chunk.blocks_name[ v3 ] )
      end
    end
  end
end

--- Add a bock to the data and save.
---@param position vector
---@param block string
function o.add_block( position, block )
  local chunk_pos = o.get_chunk_position( position )
  local chunk = o.get_chunk( chunk_pos )
  chunk:set_block( position, block )
  chunk:save()
end

-- Set a bock to the data.
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

--- Save all chunks to file.
function o.save_all_chunk()
  for k1, v1 in pairs( o.chunks ) do
    for k2, v2 in pairs( v1 ) do
      v2:save()
    end
  end
end

--- Load all chunk files.
function o.load_all_chunk()
  local files = fs.list( o.SAVE_FOLDER )
  for i = 1, #files do
    local x, z = string.gmatch( files[ i ], "(-?%d+)%-(-?%d+)" )()
    local chunk_pos = { x = tonumber( x ), z = tonumber( z ) }
    local chunk = Chunk.load( chunk_pos )
    if chunk == nil then
      CLogManager.log_error( "load_all_chunk(): chunk " .. chunk_pos.x .. "-" .. chunk_pos.z .. " is nil?" )
    else
      o.chunks[ chunk.position.x ] = o.chunks[ chunk.position.x ] or {}
      o.chunks[ chunk.position.x ][ chunk.position.z ] = chunk
    end
  end
end

--- Iterate over an outward spiral from the origin.
---@return Chunk
function o.get_next_chunk_to_explore()
  -- Position of the computer's chunk.
  local pos = settings.get( "position" )
  local chunk_pos = o.get_chunk_position( pos )
  local x, y = 0, 0
  local dx, dy = 0, -1

  while true do
    local X, Z = chunk_pos.x + x, chunk_pos.z + y
    local next_chunk_pos = { x = X, z = Z }
    -- If we don't have the chunk data OR there is not already a scouting task OR the chunk is not covered.
    if not o.chunks[ X ] or not o.chunks[ X ][ Z ] or not ( TaskRepository.is_scouting( next_chunk_pos ) or o.chunks[ X ][ Z ]:is_covered() ) then
      return o.get_chunk( next_chunk_pos )
    end
    -- Change direction.
    if x == y or ( x < 0 and x == -y ) or ( x > 0 and x == 1 - y ) then
        dx, dy = -dy, dx
    end
    x, y = x + dx, y + dy
  end
end

--- If the first chunk is covered.
--- It must be so we can place stuff and start scouting outward.
---@return boolean
function o.is_first_chunk_covered()
  if o.first_chunk_covered then return true end
  local chunk_pos = o.get_chunk_position( pos )
  local chunk = o.get_chunk( chunk_pos )
  o.first_chunk_covered = chunk:is_covered()
  return o.first_chunk_covered
end

return o