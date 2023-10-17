---@class Chunk A Minecraft chunk.
---@field position { x: integer, z: integer } The chunk coordinate.
---@field highest_block_height integer The highest block in the chunk.
---@field blocks table<integer, table<integer, table<integer, integer>>>> The id of the blocks at the position in the world.
---@field blocks_name table<integer, string> The list of block in the chunk.
Chunk = {}
Chunk.__index = Chunk
Chunk.SIZE = 15

local SAVE_FOLDER = "data/chunks/"

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

--- Add a block and save the chunk.
---@param position vector World position.
---@param block string Block's name.
function Chunk:add_block( position, block )
  self:set_block( position, block )
  self:save()
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

--- The chunk is covered if all x and z position contain at least block.
---@return boolean covered If the chunk is coverd.
function Chunk:is_covered()
  local world_pos = self:get_start_position()
  for x = 0, 15 do
    for z = 0, 15 do
      -- Find the first block in the y axis.
      local has_block = false
      for y = -64, 320 do
        local block_pos = vector.new( world_pos.x + x, y, world_pos.z + z )
        if self:get_block( block_pos ) then
          has_block = true
          break
        end
      end
      -- There is no block covering this position.
      if not has_block then return false end
    end
  end
  return true
end

--- Save a chunk file.
function Chunk:save()
  -- First and second sections are the block's mod name then the blocks name.
  -- Get all the mods name.
  local mods = {}
  for _, v in ipairs( self.blocks_name ) do
    mods[ v:match( "[^:]+" ) ] = 1
  end
  -- Set the mods id.
  local mods_id = {}
  local mods_name = {}
  local id = 1
  for k, _ in pairs( mods ) do
    mods_id[ k ] = id
    table.insert( mods_name, k )
    id = id + 1
  end
  -- Replace the mod's name to their id in the blocks name.
  local blocks = {}
  for _, v in ipairs( self.blocks_name ) do
    local mod = v:match( "[^:]+" )
    local new_name = v:gsub( mod, mods_id[ mod ] )
    table.insert( blocks, new_name )
  end
  -- Third is the known blocks positions.
  local over_block = {}
  local under_block = {}
  local over_air = {}
  local under_air = {}
  for k1, v1 in pairs( self.blocks ) do
    for k2, v2 in pairs( v1 ) do
      for k3, v3 in pairs( v2 ) do
        -- Combine the x and z value in the same number.
        -- The first 4 bit are x, the next 4 are z.
        local combined = bit.blshift( k1 % 16, 4 ) + ( k3 % 16 )
        -- The y value. Add 64 to get a positive number.
        local y = k2 + 64
        -- The block id.
        local block_id = v3
        -- If y is over 255 with a block id.
        if block_id > 0 and y >= 256 then
          y = y - 256
          table.insert( over_block, string.pack( "BBB", combined, y, block_id ) )
        -- If y is under 255 with a block id.
        elseif block_id > 0 then
          table.insert( under_block, string.pack( "BBB", combined, y, block_id ) )
        -- If y is over 255 with air.
        elseif y > 255 then
          y = y - 256
          table.insert( over_air, string.pack( "BB", combined, y ) )
        -- If y is under 255 with air.
        else
          table.insert( under_air, string.pack( "BB", combined, y ) )
        end
      end
    end
  end
  -- Open the file in write binary mode.
  local file = fs.open( SAVE_FOLDER .. self.position.x .. "-" .. self.position.z .. ".bin", "wb" )
  -- Writes to the file.
  local s = string.char( 255 )
  local ss = s .. s
  local sss = ss .. s
  file.write( table.concat( mods_name, "|" ) .. s )
  file.write( table.concat( blocks, "|" ) .. s )
  file.write( table.concat( over_block ) .. sss )
  file.write( table.concat( under_block ) .. sss )
  file.write( table.concat( over_air ) .. ss )
  file.write( table.concat( under_air ) )
  file.close()
end

--- Load the chunk if available file.
--- NOTE: DO NOT SAVE THE CHUNK WHILE LOADING.
---@param chunk_pos { x: integer, z: integer }
function Chunk.load( chunk_pos )
  -- Get the file name.
  local chunk_key = chunk_pos.x .. "-" .. chunk_pos.z
  CLogManager.log_info( "Loading chunk: " .. chunk_key )
  -- Check if it exists.
  if not fs.exists( SAVE_FOLDER .. chunk_key .. ".bin" ) then return nil end
  -- Create a new chunk instance.
  local new_chunk = Chunk.new( chunk_pos )
  -- Open the file.
  local file = fs.open( SAVE_FOLDER .. chunk_key .. ".bin", "rb" )
	local mods = {}
	local blocks = {}
	local buffer = ""
  local counter = 1
  local step = 0
  -- Read until all string sections are done.
	while true do
		local byte = file.read()
    -- The mods name until 0xFF
		if step == 0 then
			-- Done with the mods
			if byte == 0xFF then
				table.insert( mods, buffer )
				buffer = ""
				step = step + 1
			-- String seperator |.
      elseif byte == 0x7C then
				table.insert( mods, buffer )
				buffer = ""
			else
				buffer = buffer .. string.char( byte )
      end
		elseif step == 1 then
			-- Done with the mods
			if byte == 0xFF then
				table.insert( blocks, buffer )
				buffer = ""
				step = step + 1
				break
        -- String seperator |.
      elseif byte == 0x7C then
        table.insert( blocks, buffer )
        buffer = ""
        -- mod seperator :.
      elseif byte == 0x3A then
        local mod_id = tonumber( buffer )
        buffer = mods[ mod_id ] .. ":"
      else
        buffer = buffer .. string.char( byte )
        counter = counter + 1
      end
    end
  end

  -- Read the blocks position sections.
  local file_done = false
	while not file_done do
    local changed_step = false
    local x_z = 0
    local y = 0
    local block_id = 0

		-- 2. Positions above 255 with blocks.
		if step == 2 then
      x_z = file.read()
      y = file.read()
      block_id = file.read()
      -- If we get 3 0xFF the step is done.
      if x_z == 0xFF and y == 0xFF and block_id == 0xFF then
        changed_step = true
      else
        y = y - 64 + 256
      end
    -- 3. Positions below 255 with blocks.
    elseif step == 3 then
      x_z = file.read()
      y = file.read()
      block_id = file.read()
      -- If we get 3 0xFF the step is done.
      if x_z == 0xFF and y == 0xFF and block_id == 0xFF then
        changed_step = true
      else
        y = y - 64
      end
    -- 4. Positions above 255, only air.
    elseif step == 4 then
      x_z = file.read()
      y = file.read()
      -- If we get 3 0xFF the step is done.
      if x_z == 0xFF and y == 0xFF then
        changed_step = true
      else
        y = y - 64 + 256
      end
    -- 5. Positions below 255, only air.
    elseif step == 5 then
      x_z = file.read()
      y = file.read()
      -- If we get nil then the file is done.
      if x_z == nil then
        changed_step = true
        file_done = true
      else
        y = y - 64
      end
    end

    -- If it's data, process it.
    if not changed_step then
      -- And with 0x0F to get the z.
      local z = bit.band( x_z , 0x0F )
      -- Shift right 4 bit to get the x.
      local x = bit.brshift( x_z, 4 )
      -- Get the world position.
      local pos = vector.new( x + ( 16 * chunk_pos.x ), y, z + ( 16 * chunk_pos.z ) )
      -- Set the block so we know the highest position.
      if block_id == 0 then
        new_chunk:set_block( pos, "air" )
      else
        new_chunk:set_block( pos, blocks[ block_id ] )
      end
    else
      step = step + 1
    end
  end

  file.close()
  return new_chunk
end

return Chunk