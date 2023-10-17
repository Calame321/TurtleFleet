---@class CraftingOption An option to craft a resource.
---@field recipe_name string The name of the recipe to use.
---@field qty_of_item_per_craft integer The quantity of item crafted.
---@field number_of_craft_operation_needed integer The quantity of crafting operation we need to do.
---@field qty_of_craft_available integer The quantity of crafting operation we can do.
---@field crafting_node CraftingNode[] The resource nodes. 
CraftingOption = {}
CraftingOption.__index = CraftingOption

--- Create a crafting node from a recource.
---@param recipe_name string
function CraftingOption.new( recipe_name )
  local self = setmetatable( {}, CraftingOption )
  self.recipe_name = recipe_name
  self.number_of_craft_operation_needed = 1
  self.qty_of_craft_available = 1
  self.crafting_node = {}
  return self
end

--- Set the amount of time we can craft this recipe option.
---@param recipe Recipe
function CraftingOption:set_crafting_quantity( recipe )
  self.qty_of_craft_available = 9999999
  -- For each of the ingredient's crafting node.
  for _, node in ipairs( self.crafting_node ) do
    -- Get the total quantity available.
    local total = node.qty_available_by_crafting + node.qty_available
    -- Get the ingredient's resource.
    for _, ingredient in pairs( recipe.ingredients ) do
      if ingredient == node.resource then
        -- Set the amount of time we can craft this recipe from the lowest available ingredient.
        self.qty_of_craft_available = math.min( self.qty_of_craft_available, math.ceil( total / ingredient.quantity ) )
        break
      end
    end
  end
  if self.qty_of_craft_available == 9999999 then self.qty_of_craft_available = 0 end
end

return CraftingOption