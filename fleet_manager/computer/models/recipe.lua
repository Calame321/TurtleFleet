---@class Recipe
---@field name string The name of the recipe file.
---@field type "minecraft:crafting_shaped"|"minecraft:crafting_shapeless"
---@field ingredients Resource[]
---@field pattern string[]|nil
---@field result {item: string, count: integer}
---@field group string A group of recipes that help to figure out the crafting tree.
Recipe = {}
Recipe.__index = Recipe

--- Create a new recipe.
---@return Recipe
function Recipe.new( name, type, ingredients, pattern, result, group )
  local self = setmetatable( {}, Recipe )
  self.name = name
  self.type = type
  self.ingredients = ingredients
  self.pattern = pattern
  self.result = result
  self.group = group
  return self
end

--- Copy a recipe instance.
---@return Recipe
function Recipe:copy()
  local data = textutils.serialize( self )
  local new_self = textutils.unserialize( data )
  new_self = setmetatable( new_self, Recipe )
  -- Set resource's metatable.
  for _, resource in ipairs( new_self.ingredients ) do
    resource = setmetatable( resource, Resource )
  end
  return new_self
end

--- Check if the recipe can craft an item by it's name.
---@param resource Resource
---@return boolean
function Recipe:is_for( resource )
  for item in resource:iterator() do
    if ( item.name and self.result.item and item.name == self.result.item ) or ( item.tag and self.result.tag and item.tag == self.result.tag ) then
      return true
    end
  end
  return false
end

--- Return the ingredients for the recipe.
---@return Resource[]
function Recipe:get_ingredients()
  local ingredients = {}
  local array_to_copy = self.ingredients
  if type == "minecraft:crafting_shapeless" then
    array_to_copy = self.ingredients
  end
  for _, resource in pairs( array_to_copy ) do
    table.insert( ingredients, Resource.copy( resource ) )
  end
  return ingredients
end

return Recipe
