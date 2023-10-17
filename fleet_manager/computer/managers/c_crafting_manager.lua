---@class CCraftingManager
---@field recipes Recipe[]
local o = {}
local RecipeRepository = require( "repositories.recipe_repository" )
local TagRepository = require( "repositories.tag_repository" )
TagRepository.load_all()

o.recipes = {}
o.turtle_crafting_grid_index = { 1, 2, 3, 5, 6, 7, 9, 10, 11 }

--- Get the crafting tree sequence to craft a resource. The items are reserved in the storage.
---@param resource Resource
---@return CraftingNode crafting_tree
function o.get_crafing_tree( resource )
  local reserve_id = StorageManager.start_new_reserve()
  local crafting_tree = o.can_craft( resource, nil, reserve_id )
  CLogManager.log_info( "reserve_id: " .. reserve_id )
  if not crafting_tree:craftable() then
    StorageManager.unreserve( reserve_id )
    CLogManager.log_info( "Not craftable..." )
  end
  CLogManager.log_info( "Crafting tree done." )
  return crafting_tree
end

--- Check if the item can be crafted. else give me the items I need to craft or gather.
---@param resource Resource
---@param parent CraftingNode|nil
---@param reserve_id integer
---@return CraftingNode
function o.can_craft( resource, parent, reserve_id )
  -- Create the node.
  local crafting_node = CraftingNode.new( resource, reserve_id )
  -- Get the quantity of items aleready in storage.
  crafting_node:add_quantity( StorageManager.add_to_reserve( resource, reserve_id ) )
  -- If we have enough of this resource, return.
  if crafting_node:has_enough() then return crafting_node end
  -- Get the valid recipes.
  local valid_recipes = RecipeRepository.get_recipes_for( resource )

  -- For each recipes, add a table { recipe, CraftingNode[] }
  for _, recipe in ipairs( valid_recipes ) do
    local crafting_option = CraftingOption.new( recipe.name )
    local is_looping_recipe = false
    local has_enough_to_craft = true
    -- For each ingredients.
    for _, recipe_ingredient in pairs( recipe.ingredients ) do
      local ingredient = recipe_ingredient:copy()
      -- Prevent recipe loop. If the ingredient is the same as the reosurce of the parent. (ex: iron ingot -> Iron block -> Iron ingot)
      if parent and parent.resource == ingredient then
        is_looping_recipe = true
        break
      end
      -- The amount of time we need to perform the crafting operation to get the desired quantity.
      crafting_option.number_of_craft_operation_needed = math.ceil( crafting_node.qty_to_get / recipe.result.count )
      -- The amount of ingredient we will need in total.
      ingredient.quantity = crafting_option.number_of_craft_operation_needed * ingredient.quantity
      -- Can we craft the ingredient.
      local node = o.can_craft( ingredient, crafting_node, reserve_id )
      -- Check if we have enough resources.
      has_enough_to_craft = has_enough_to_craft and node:has_enough()
      table.insert( crafting_option.crafting_node, node )
    end
    -- Set the quantity of item available from crafting options.
    local qty_of_item_crafted_from_this_recipe = crafting_option.number_of_craft_operation_needed * recipe.result.count
    crafting_node.qty_available_by_crafting = crafting_node.qty_available_by_crafting + qty_of_item_crafted_from_this_recipe
    -- Change the available quantity of the node based on the number of time we can craft the recipe.
    crafting_option:set_crafting_quantity( recipe )
    -- Add the recipe if it's not looping.
    if not is_looping_recipe then crafting_node:add_option( crafting_option ) end
    -- If we have enough to do a recipe, keep only that last one, break;
    if has_enough_to_craft then
      crafting_node:keep_last_option()
      break
    end
  end
  return crafting_node
end

--- Change the tags in the resource for item name only.
---@param resource Resource
function o.resource_tag_to_items( resource )
  TagRepository.load_all()
  local new_resource = Resource.new( nil, resource.quantity )
  for item in resource:iterator() do
    if item.name then
      new_resource:add( "name", item.name )
    else
      -- Load all the item from the tag.
      local items = TagRepository.tags[ item.tag ]
      for _, v in ipairs( items ) do
        new_resource:add( "name", v )
      end
    end
  end
  return new_resource
end

--- Perform the crafting operations needed to craft the desired resource.
---@param crafting_node CraftingNode
function o.craft( crafting_node )
  -- If there is at least 1 crafting option.
  if #crafting_node.crafting_options > 0 then
    -- For each option.
    for _, option in ipairs( crafting_node.crafting_options ) do
      -- Craft the item of each nodes.
      for _, node in ipairs( option.crafting_node ) do
        o.craft( node )
      end
      -- Get the recipe to craft this option.
      local recipe = RecipeRepository.get_recipe_by_name( option.recipe_name )
      if recipe == nil then error("CraftingManager.craft(): Recipe is nil?") end
      -- For each ingredients of the recipe.
      for _, ingredient in ipairs( recipe.ingredients ) do
        -- Copy the ingredient so we don't modify the original.
        local resource = Resource.copy( ingredient )
        -- Set the quantity to use as the number of crafting operation needed.
        resource.quantity = option.qty_of_craft_available
        -- Shaped recipe.
        if recipe.type == "minecraft:crafting_shaped" then
          -- For each pattern row.
          for y, row_pattern in ipairs( recipe.pattern ) do
            for x = 1, #row_pattern do
              if ingredient.code == row_pattern:sub( x, x ) then
                local turtle_slot_index = ( ( y - 1) * 4 ) + x
                StorageManager.transfer_item_to_crafting_turtle( resource, turtle_slot_index )
              end
            end
          end
        -- Shapeless.
        elseif recipe.type == "minecraft:crafting_shapeless" then
          local item_transfered = false
          for x = 1, 3 do
            for y = 1, 3 do
              if StorageManager.transfer_item_to_crafting_turtle( resource, ( ( y - 1) * 4 ) + x ) then
                item_transfered = true
                break
              end
            end
            if item_transfered then break end
          end
        end
      end

      CNetworkManager.send_craft_request( peripheral.call( "back", "getID" ) )
      StorageManager.empty_crafting_turtle()
    end
  end
end

return o
