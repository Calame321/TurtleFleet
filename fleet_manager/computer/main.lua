---@class Main
local o = {}

local STARTING_KIT = 10
local BUILD_TREE_FARM = 20
local CRAFT_TURTLE = 30
local BUILD_NETWORK_STORAGE = 30

local secondary_checks = {
  "Fuel level"
}

local current_goal = BUILD_TREE_FARM

--- The main loop. It will create tasks based on the current goal and available resources.
function o.main()
  while true do
      if current_goal == STARTING_KIT then
        -- Build the satelite array:
        --   place the disk drive.
        --   place the disk in it.
        --   place the computer on top.
        --   place the computer's modem.
        --   Turn the computer on.
        --   do it for the 4 computers.
        --   Build - First Storage
      elseif current_goal == BUILD_TREE_FARM then
        if WorldManager.first_chunk_covered then
          o.build_tree_farm()
        else
          CTaskManager.generate_task( "scouting" )
        end
      end

      local _, key = os.pullEvent( "key" )
      if key == keys.b then CTaskManager.generate_task( "building" ) end
      if key == keys.s then CTaskManager.generate_task( "scouting" ) end
      if key == keys.h then CTaskManager.generate_task( "return home" ) end
      if key == keys.c then
        CLogManager.log_info( "crafting..." )
        local item_to_craft = Resource.new( { name = "minecraft:sticky_piston" }, 6 )
        local t = CCraftingManager.get_crafing_tree( item_to_craft )
        local f = fs.open( "test", "w" )
        f.write( textutils.serialize( StorageManager.reserved_items[ t.reserve_id ] ) )
        f.close()
        f = fs.open( "test2", "w" )
        f.write( textutils.serialize( t ) )
        f.close()
        --CCraftingManager.craft( t )
        CLogManager.log_info( "crafting done!" )
      end
  end
end

function o.build_tree_farm()
  local has_chest = StorageManager.has_item( "chest" )
  local has_furnace = StorageManager.has_item( "furnace" )
  local has_sapling = StorageManager.has_item( "sapling" )

  if not has_chest then
    local missing_items = CCraftingManager.can_craft( "minecraft:chest" )
  end

  if not has_furnace then
    --    Work - Mine
    o.craft( "minecraft:furnace" )
  end

  if not has_sapling then
    o.chop_tree()
  end

  if has_chest and has_furnace and has_sapling then
    StorageManager.reserve_items( { { item = "chest", quantity = 1 }, { item = "furnace", quantity = 1 }, { item = "sapling", quantity = "*" }} )
    CTaskManager.generate_task( "build_tree_farm" )
  end
end

function o.craft( item )
  if item == "chest" then
    if not StorageManager.has_item( "planks" ) then
      o.craft( "planks" )
      --     Scout - Log
    end
  end
end

function o.chop_tree()
  local tree_location = nil

  if tree_location == nil then
    o.scout_for( "tree" )
  else
    CTaskManager.generate_task( "chop_tree" )
  end
end

return o