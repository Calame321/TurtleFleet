---@class Resource
---@field item {name: string|nil, tag: string|nil}|{name: string|nil, tag: string|nil}[]|nil
---@field quantity integer
---@field code string|nil Used if it's for a shaped recipe.
Resource = {}
Resource.__index = Resource

--- Resource constructor from an item name and an optional quantity.
---@param item {item: string|nil, tag: string|nil}|nil
---@param quantity integer
function Resource.new( item, quantity, code )
  local self = setmetatable( {}, Resource )
  self.item = item
  self.quantity = quantity or 1
  self.code = code or nil
  return self
end

--- Create a resource from a raw resource table.
---@param data table
---@return Resource
function Resource.from_table( data )
  local self = setmetatable( {}, Resource )
  -- If it's an array.
  if data[ 1 ] then
    for _, v in ipairs( data ) do
      if v.item then
        self:add( "name", v.item )
      else
        self:add( "tag", v.tag )
      end
    end
  else
    -- If it's a single tag or item.
    if data.item then
      self:add( "name", data.item )
    else
      self:add( "tag", data.tag )
    end
  end
  self.quantity = 1
  return self
end

--- Resource constructor from a resource.
---@param resource Resource
function Resource.copy( resource )
  local json = textutils.serializeJSON( resource )
  local self = textutils.unserializeJSON( json )
  self = setmetatable( self, Resource )
  return self
end

--- Deal with adding the item data and changing it to an array if needed.
---@param name_or_tag string
---@param value string
function Resource:add( name_or_tag, value )
  -- If there is no item, set it.
  if self.item == nil then
    self.item = { [ name_or_tag ] = value }
    return
  end
  -- If it's not an array but there is one item, change it to an array.
  if not self:is_array() then self.item = { self.item } end
  -- Ad the data in the array.
  table.insert( self.item, { [ name_or_tag ] = value } )
end

--- If we want to know if an item is valid for this resource.
--- ex: is an oak_planks valid for a tag: 'minecraft:plank'
---@param item Item
---@return boolean
function Resource:is_item_valid( item )
  if self:is_array() then
    for _, v in ipairs( self.item ) do
      if Resource.is_valid( v, item ) then return true end
    end
    return false
  end
  return Resource.is_valid( self.item, item )
end

--- If the item can be used for this resource.
---@param resource_item {name: string|nil, tag: string|nil}
---@param item Item
---@return boolean
function Resource.is_valid( resource_item, item )
  -- If the name match.
  if resource_item.name ~= nil then return resource_item.name == item.name end
  -- If the item has the tag.
  return item:has_tag( resource_item.tag )
end

--- If this resource has multiple possible items.
--- ex: coal, charcoal
---@return boolean
function Resource:is_array()
  return self.item[ 1 ] ~= nil
end

--- Compare 2 resource to check if they target the same item or tag.
---@param resource1 Resource
---@param resource2 Resource
---@return boolean
function Resource.__eq( resource1, resource2 )
  -- They are both arrays or not.
  if resource1:is_array() ~= resource2:is_array() then return false end
  -- If they are arrays, do all item match?
  if resource1:is_array() then

    -- TODO: Use the iterator.

    for k, r1_item in ipairs( resource1.item ) do
      local r2_item = resource2.item[ k ]
      if r1_item.name ~= r2_item.name or r1_item.tag ~= r2_item.tag then return false end
    end
    return true
  end
  -- if not array, do the item match?
  return resource1.item.name == resource2.item.name and resource1.item.tag == resource2.item.tag
end

--- Iterator usable in a for loop.
---@return function iterator The iterator function.
function Resource:iterator()
  local i = 0
  return function()
    i = i + 1
    if self:is_array() then
      return self.item[ i ]
    else
      if i == 1 then return self.item end
    end
    return nil
  end
end

function Resource:print( title )
  print( ( title or "" ) .. textutils.serialize( self ) )
end
