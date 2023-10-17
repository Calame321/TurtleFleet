---@class CraftingNode The main node for crafting. It can be a tag containing multiple different items. (A resource)
---@field resource Resource The resource used to get the crafting options.
---@field qty_needed integer The quantity of item needed.
---@field qty_to_get integer The quantity of item we need to get for this node.
---@field qty_available integer The quantity available from all the inventory.
---@field qty_available_by_crafting integer The quantity available from crafting.
---@field crafting_options CraftingOption[] The recipes available to craft the resource.
---@field reserve_id integer The id of the list of reserved items for the crafting tree this node is in.
CraftingNode = {}
CraftingNode.__index = CraftingNode

--- Create a crafting node from a recource.
---@param resource Resource
---@param reserve_id integer
function CraftingNode.new( resource, reserve_id )
  local self = setmetatable( {}, CraftingNode )
  self.resource = resource
  self.qty_needed = resource.quantity
  self.qty_to_get = 0
  self.qty_available = 0
  self.qty_available_by_crafting = 0
  self.crafting_options = {}
  self.reserve_id = reserve_id
  return self
end

--- Keep only the last recipe added. (It has the availabe items to craft.)
function CraftingNode:keep_last_option()
  self.crafting_options = { self.crafting_options[ #self.crafting_options ] }
end

--- Add a quantity of items we have for this resource. (In inventory or craftable.)
---@param quantity integer
function CraftingNode:add_quantity( quantity )
  self.qty_available = math.min( self.qty_available + quantity, self.qty_needed )
  self.qty_to_get = math.max( 0, self.qty_needed - self.qty_available )
end

--- Ad a new option to craft this resource.
---@param crafting_option any
function CraftingNode:add_option( crafting_option )
  table.insert( self.crafting_options, crafting_option )
end

--- If we have enough item to craft it.
---@return boolean
function CraftingNode:has_enough()
  return self.qty_to_get == 0
end

--- If we have enough item to craft it after crafting sub recipe.
---@return boolean
function CraftingNode:craftable()
  return self.qty_available_by_crafting + self.qty_available >= self.qty_to_get
end

return CraftingNode