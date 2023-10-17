local PLANKS = Item.planks()
local CHEST = Item.chest()
local LOG_TAG = { tag = "minecraft:logs" }

return {
  Recipe.new( { "minecraft:chest", "minecraft:oak_planks" }, { 1 }, { [ 2 ] = 8 }, { 1 }, { 2, 2, 2, 2, nil, 2, 2, 2, 2 } ),
  Recipe.new( { "minecraft:oak_planks", "minecraft:oak_log" }, { 4 }, { [ 2 ] = 1 }, { 1 }, { 2 } ),
}