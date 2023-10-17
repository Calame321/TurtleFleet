---@class Inventory An inventory that can be connected to the network. managed by the storage manager.
---@field name string The name of the inventory.
---@field size integer The number of slots in the inventory.
---@field items table<integer, { item: string, quantity: integer}> The items in each slots.
---@field position vector[] The position of the inventory in the world. Can be multiple blocks.
Inventory = {}
Inventory.__index = Inventory

--- Constructor for creating a new Inventory instance.
---@param size integer
---@return Inventory
function Inventory.new( name, size )
    local self = setmetatable( {}, Inventory )
    self.name = name
    self.size = size
    self.items = {}
    self.position = {}
    return self
end

--- Set an item in the inventory.
---@param item string The item name.
---@param count integer Quantity of the item.
---@param index integer The slot position.
function Inventory:set_item( item, count, index )
    self.items[ index ] = { item = item, quantity = count }
end

--- Check if the inventory is full.
---@return boolean
function Inventory:is_full()
    return #self.items >= self.size
end

--- Get the contents of the inventory.
---@return table<integer, { item: string, quantity: integer }>
function Inventory:get_contents()
    return self.items
end

return Inventory