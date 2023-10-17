Chunk = {}
Chunk.__index = Chunk
Chunk.SIZE = 15

--- Chunk constructor.
---@param position vector
---@return Chunk
function Chunk.new( position )
  local self = setmetatable( {}, Chunk )
  self.position = position or { x = 0, z = 0 }
  self.highest_block_height = -64
  self.blocks = {}
  self.blocks_name = { [ 0 ] = "air" }
  return self
end

--- Refresh the field of the object.
---@param chunk Chunk The chunk to refresh. (set the metatable.)
---@return Chunk # Refreshed chunk.
function Chunk.refresh( chunk )
  local self = setmetatable( {}, Chunk )
  self.position = chunk.position or { x = 0, z = 0 }
  self.highest_block_height = chunk.highest_block_height or -64
  self.blocks = chunk.blocks or {}
  self.blocks_name = chunk.blocks_name or { [ 0 ] = "air" }
  return self
end

--- Get the id of the block by it's name.
--- Used to store only the id at the position and reduce space.
---@param name string
---@return integer
function Chunk:get_block_id( name )
  -- If it's air.
  if name == "air" then return 0 end
  -- get the existing id.
  for k, v in ipairs( self.blocks_name ) do
    if v == name then
      return k
    end
  end
  -- Add a new block name and return the index.
  table.insert( self.blocks_name, name )
  return #self.blocks_name
end

--- Set a block at a position.
---@param position vector Position of the block.
---@param block string The name of the block.
function Chunk:set_block( position, block )
  self.blocks[ position.x ] = self.blocks[ position.x ] or {}
  self.blocks[ position.x ][ position.y ] = self.blocks[ position.x ][ position.y ] or {}
  self.blocks[ position.x ][ position.y ][ position.z ] = self:get_block_id( block )
  -- Change the highest block height if it's not air.
  if block ~= "air" and self.highest_block_height < position.y then self.highest_block_height = position.y end
end

--- Get a block at a position.
---@param pos vector Position we want to get the block.
---@return string # Block name.
function Chunk:get_block( pos )
  self.blocks[ pos.x ] = self.blocks[ pos.x ] or {}
  self.blocks[ pos.x ][ pos.y ] = self.blocks[ pos.x ][ pos.y ] or {}
  return self.blocks_name[ self.blocks[ pos.x ][ pos.y ][ pos.z ] ]
end

--- Get coordinates range of the chunk.
---@return vector min The lowest chunk border position.
---@return vector max The highest chunk morder position.
function Chunk:get_range()
  local start_pos = self:get_start_position()
  local min = vector.new( start_pos.x, 0, start_pos.z )
  local max = vector.new( start_pos.x + 15, 0, start_pos.z + 15 )
  return min, max
end

--- Get the north west world position of the chunk.
---@return vector # The chunk's north west world position.
function Chunk:get_start_position()
  -- Get the x coord toward the west. (negative)
  local x = bit.blshift( math.abs( self.position.x ), 4 )
  -- If the chunk pos is negative.
  if self.position.x < 0 then
    x = ( x - 1 ) * -1
  end
  -- Get the z coord toward the west. (negative)
  local z = bit.blshift( math.abs( self.position.z ), 4 )
  -- If the chunk pos is negative.
  if self.position.z < 0 then
    z = ( z - 1 ) * -1
  end
  return vector.new( x, 0, z )
end

return Chunk