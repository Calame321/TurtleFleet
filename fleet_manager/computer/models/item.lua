---@class Item
---@field name string|nil
---@field tags string[]
---@field quantity integer
Item = {}
Item.__index = Item

--- Create a new item instance.
---@param name string|nil Name of the item.
---@param tags string[]|nil Tags of the item.
---@param quantity integer|nil Will default to 1 if nil.
function Item.new( name, tags, quantity )
  local self = setmetatable( {}, Item )
  self.name = name
  self.tags = tags or {}
  self.quantity = quantity or 1
  return self
end

--- Create a new item instance from another.
---@param item Item Item to copy.
function Item.neu( item )
  return Item.new( item.name, item.tags, item.quantity )
end

--- Add to the item quantity.
---@param quantity integer
function Item:add( quantity )
  self.quantity = self.quantity + quantity
end

--- If this item has the tag.
---@param tag string
---@return boolean
function Item:has_tag( tag )
  return table.contains( self.tags, tag )
end

--- Specific items
function Item.chest() return Item.new( "minecraft:chest", nil, nil ) end
function Item.planks( quantity )  return Item.new( nil, { "minecraft:planks" }, quantity ) end

return Item