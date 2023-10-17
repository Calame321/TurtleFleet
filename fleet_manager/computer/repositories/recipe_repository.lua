require( "models.recipe" )
require( "models.resource" )

local o = {}

o.recipes = {}

local RECIPE_FOLDER = "data/recipes"

--- Get the recipe for an item.
---@param resource Resource
---@return Recipe[]
function o.get_recipes_for( resource )
  local valid_recipes = {}
  for _, recipe in ipairs( o.recipes ) do
    if recipe:is_for( resource ) then
      -- If it's a tag recipe, return just this one.
      if recipe.result.tag then return { recipe } end
      table.insert( valid_recipes, recipe )
    end
  end
  return valid_recipes
end

--- Get a recipe by it's name.
---@param recipe_name string
---@return Recipe|nil
function o.get_recipe_by_name( recipe_name )
  for _, recipe in ipairs( o.recipes ) do
    if recipe.name == recipe_name then
      return recipe
    end
  end
  return nil
end

--- Load all tags.
function o.load_all()
  local mods = fs.list( RECIPE_FOLDER )
  for i = 1, #mods do
    local recipe_files = fs.list( RECIPE_FOLDER .. "/" .. mods[ i ] )
    for j = 1, #recipe_files do
      local file = recipe_files[ j ]
      local recipe_name = mods[ i ] .. ":" .. string.gmatch( file, "(.+)%.json" )()
      local f = fs.open( RECIPE_FOLDER .. "/" .. mods[ i ] .. "/" .. recipe_files[ j ], "r" )
      local content = f.readAll()
      local json_recipe = textutils.unserialiseJSON( content )
      f.close()
      local type = json_recipe.type
      if type == "minecraft:crafting_shaped" then
        o.load_shaped( recipe_name, type, json_recipe )
      elseif type == "minecraft:crafting_shapeless" then
        o.load_shapeless( recipe_name, type, json_recipe )
      elseif type == "minecraft:smelting" then
        o.load_smelting( recipe_name, type, json_recipe )
      end
    end
  end
end

--- Load a pattern recipe.
---@param type string
---@param json_recipe table
function o.load_shaped( recipe_name, type, json_recipe )
  -- Get the keys for the pattern.
  local ingredients = {}
  for code, raw_resource in pairs( json_recipe.key ) do
    local r = Resource.from_table( raw_resource )
    r.code = code
    table.insert( ingredients, r )
  end
  -- Get the pattern.
  local pattern = json_recipe.pattern
  -- Get the result.
  local result = json_recipe.result
  if result[ "count" ] == nil then result[ "count" ] = 1 end
  -- Count the quantity of each resources.
  for _, v in pairs( ingredients ) do
    local total_pattern = table.concat( pattern )
    local total = 0
    for i = 1, #total_pattern do if total_pattern:sub( i, i ) == v.code then total = total + 1 end end
    v.quantity = total
  end
  -- The recipe group.
  table.insert( o.recipes, Recipe.new( recipe_name, type, ingredients, pattern, result, json_recipe.group ) )
end

--- Load a pattern recipe.
---@param type string
---@param json_recipe table
function o.load_shapeless( recipe_name, type, json_recipe )
  -- Get the ingredients.
  local ingredients = {}
  for _, ingredient in ipairs( json_recipe.ingredients ) do
    local r = Resource.from_table( ingredient )
    table.insert( ingredients, r )
  end
  -- Get the result.
  local result = json_recipe.result
  if result[ "count" ] == nil then result[ "count" ] = 1 end
  table.insert( o.recipes, Recipe.new( recipe_name, type, ingredients, nil, result, json_recipe.group ) )
end

function o.load_smelting( recipe_name, type, json_recipe )
  -- Get the ingredients.
  local ingredients = {}
  local r = Resource.from_table( json_recipe.ingredient )
  table.insert( ingredients, r )
  -- Get the result.
  local result = { item = json_recipe.result, count = 1 }
  table.insert( o.recipes, Recipe.new( recipe_name, type, ingredients, nil, result, json_recipe.group ) )
end

function o.get_groups()
  local groups = {}
  for _, recipe in ipairs( o.recipes ) do
    if recipe.group then
      table.insert_if_not_contains( groups, recipe.group )
    end
  end
  return groups
end

o.load_all()
return o
-- r = require("repositories.recipe_repository"); r.get_recipes_for( Resource.new( { tag = "minecraft:planks" }, 40 ) )