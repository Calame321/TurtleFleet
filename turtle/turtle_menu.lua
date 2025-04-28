----------
-- Menu --
----------
local miner = require( "miner" )
local builder = require( "builder" )
local smelter = require( "smelter" )
local fleet = require( "fleet_mode" )
local harvester = require( "harvester" )
local lumberjack = require( "lumberjack" )

local w, h = term.getSize()
local current_menu = {}

function display_menu( menu )
  current_menu = menu
  term.clear()
  show_fuel_level()
  term.setCursorPos( 1, 1 )
  print( menu.path )
  print( menu.prompt )

  for i = 1, #menu.options do
    print( menu.options[ i ].name )
  end

  if current_menu.parent then
    term.setCursorPos( 1, h )
    write( "b - Go Back")
  end
end

-- Display the fuel level in the lower right corner of the screen.
function show_fuel_level()
  if turtle.getFuelLevel() == "unlimited" then
    local current_fuel = "Fuel: "
    local fg = "000000f0f0"
    local bg = "ffffff0f0f"
    term.setCursorPos( w - #current_fuel, h - 1 )
    term.blit( current_fuel, fg, bg )
    return
  end

  local current_fuel = "Fuel: " .. turtle.getFuelLevel() .. "/" .. turtle.getFuelLimit()
  term.setCursorPos( w - #current_fuel, h )
  write( current_fuel )
end

function show_tree_farm_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Tree Farm -" )
  print( "The turtle will plant trees and harvest them. It will also cook its own fuel." )
  print()
  print( "Length? (default = 15)")
  sleep( 0.2 )
  local input = read()
  local tree_farm_length = 15

  if input ~= "" then
    tree_farm_length = tonumber( input )
  end

  lumberjack.start( tree_farm_length )
end

function show_cane_farm()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Sugar Cane Farm -" )
  print( "Do you want me to build the farm?")
  print( "y, n? (default = no)")
  sleep( 0.2 )
  local input = read()

  if input == "y" then
    print( "Give me 2 water buckets, in slot 1 and 2. I'll also need 3 stacks of sugar cane and a chest." )
    print( "Press enter to start." )
    read()
    harvester.set_cane_farm()
  else
    harvester.start_cane_farm()
  end
end

function show_digout_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Dig out -" )
  print( "This will dig a 3 blocks high area the size you specify.")
  print( "It's recomended to set some storages before if you can." )
  print()
  print( "Depth = ?")
  sleep( 0.2 )
  local input = read()
  local depth = tonumber( input )

  print( "Width = ?")
  sleep( 0.2 )
  input = read()
  local width = tonumber( input )
  
  print( "Fill holes? (y or n)")
  sleep( 0.2 )
  input = read()
  local place_walls = input == 'y'
  miner.start_dig_out( depth, width, place_walls )
  menu.show()
end

function show_fleet_digout_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Fleet Dig out -" )
  print( "This will dig a cubic area using multiple turtles (The height given divided by 3).")
  print( "This turtle should be placed on a chest to the left." )
  print( "The depth and width is given with a renamed piece of paper. ex: '32 16'. (else default 32 x 32 will be used)")
  print( "Press enter for the chests placement.")
  sleep( 0.2 )
  read()
  print( "Chests (not needed if not in settings):" )
  print( "- Up: Fuel" )
  print( "- Down: Drop Storage" )
  print( "- Front: Turtle Storage" )
  print( "- Right: Filtered Storage" )
  print( "- Left: Buckets (if there is going to be lava)" )
  print()
  sleep( 0.2 )
  print( "Height = ? (multiple of 3)")
  sleep( 0.2 )
  input = read()
  local height = tonumber( input )

  fleet.dig_out( height )
  menu.show()
end

function show_flatten_chunk_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Flatten Chunk (16 x 16) -" )
  print( "This will flatten a 16 by 16 area. (from the back left corner). The extra height is to prevent floating blocks." )
  print( "It's recomended to set some storages before if you can." )
  print()
  print( "Number of chunk = ? (default = 1)")
  sleep( 0.2 )
  local input = read()
  local nb_chunk = 1
  if input ~= "" then nb_chunk = tonumber( input ) end
  
  print( "extra height = ? (default = 5)")
  sleep( 0.2 )
  input = read()
  local extra_height = 5
  if input ~= "" then
    extra_height = tonumber( input )
  end

  miner.start_flaten_chunks( nb_chunk, extra_height )
  menu.show()
end

function show_fleet_flatten_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Fleet Flatten Chunk -" )
  print( "This will flatten an area the width of the number of turtle used." )
  print( "This turtle should be placed on a chest to the left." )
  print( "The length is given with a renamed piece of paper. (by step of 4) ex: '64'.")
  print( "Press enter for the chests placement.")
  sleep( 0.2 )
  read()
  print( "Chests (not needed if not in settings):" )
  print( "- Up: Fuel" )
  print( "- Down: Drop Storage" )
  print( "- Front: Turtle Storage" )
  print( "- Right: Filtered Storage" )
  print( "- Left: Buckets (if there is going to be lava)" )
  print()
  print( "Give a paper renamed with the length then press enter to start.")
  sleep( 0.2 )
  read()

  if has_flaten_fleet_setup() then
    fleet.flatten()
  else
    print( "The Fleet flatten setup is invalid." )
  end

  menu.show()
end

function show_fleet_manager_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Fleet Manager -" )
  print( "This option will build the Fleet Manager system." )
  print( "It will manage the turtle by itself. You'll give your command trought the computer." )
  print( "You wont be able to control the turtles that are assigned to it.")
  print( "Press a key to continue." )
  sleep( 0.2 )
  read()
  print()
  print( "The turtle will claim this chunk, so it should be started outside in the overworld.")
  print()
  print( "Press a key for the list of material needed.")
  sleep( 0.2 )
  read()
  print( "Material:" )
  print( "- 64 Coal/Charcoal" )
  print( "- 1 Chest. (or other storage block)" )
  print( "- 4 Computer. (at least 1 advanced" )
  print( "- 5 Wireless Modem. (4 Ender Modem if possible)" )
  print( "- 1 Disk Drive" )
  print( "- 1 Disk" )
  print( "- 1 Crafting Table")
  print( "- 1 Diamond Pickaxe. (If the turtle dosen't have one)")
  print()
  sleep( 0.2 )
  read()
  print()
  print( "What is my position:" )
  print( "x = ?" )
  sleep( 0.2 )
  local x = tonumber( read() )
  print( "y = ?" )
  local y = tonumber( read() )
  print( "z = ?" )
  local z = tonumber( read() )
  print()
  print( "What direction am I facing?" )
  print( "1 - North" )
  print( "2 - East" )
  print( "3 - South" )
  print( "4 - West" )
  local facing = tonumber( read() )

  turtle.x = x
  turtle.y = y
  turtle.z = z
  if facing == "1" then turtle.dz = -1
  elseif facing == "2" then turtle.dx = 1
  elseif facing == "3" then turtle.dz = 1
  elseif facing == "4" then turtle.dx = -1
  end

  -- Get the chunk position.
  -- Place the computers and modems.
  -- Place the chest, put the crafting table inside.
  -- Place the drive and disk.
  -- Install the startup on the disk.
  -- Boot the computer.
  -- Reboot to install the fleet_manager for the turtle.

  menu.show()
end

-- Vein mine
function show_vein_mine_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Vein Mine -" )
  print( "This will mine all block specified that are connected by a side. (Diagonal dosen't work.)" )
  print()

  print( "Block to mine = ? (default = The block in front)")
  sleep( 0.2 )
  local input = read()
  if input == "" then
    local found_block, block_data = turtle.inspectDir( "forward" )
    if found_block then
      input = block_data.name
    end
  end

  miner.start_vein_mine( "forward", input )
  menu.show()
end

-- Place Ceiling
function start_place_ceiling()
  builder:place_floor( "up" )
  menu.show()
end

-- Branch mining
function show_branch_mining()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Branch Mining -" )
  print( "For this one, the turtle need to be facing a chest. It will mine the number of branches of specified of the specified length." )
  print()

  print( "The turtle should turn:" )
  print( "1 = left (default)" )
  print( "2 = right")
  sleep( 0.2 )
  local input = read()
  local branch_side = "left"

  if input == "2" then
    branch_side = "left"
  end

  print( "Number of branches? (default = 20)" )
  sleep( 0.2 )
  local input = read()
  local branch_quantity = 20
  if input ~= "" then
    branch_quantity = tonumber( input )
  end

  print( "Length of a branch? (default = 80)")
  sleep( 0.2 )
  input = read()
  local branch_length = 80
  if input ~= "" then
    branch_length = tonumber( input )
  end

  miner.start_branch_mining( branch_side, branch_quantity, branch_quantity )
  menu.show()
end

function show_current_config_page()
  display_current_storage()
  term.setCursorPos( 1, h )
  write( "press enter." )
  sleep( 0.2 )
  read()

  display_current_valid_fuel()
  term.setCursorPos( 1, h )
  write( "press enter." )
  sleep( 0.2 )
  read()

  display_current_forbidden_block()
  term.setCursorPos( 1, h )
  write( "press enter." )
  sleep( 0.2 )
  read()

  menu.show()
end

function display_current_storage()
  term.clear()
  local current_title = "- current storage, slot: type -"
  term.setCursorPos( w - #current_title, 1 )
  print( current_title )
  local line_y = 2
  for i = 1, 16 do
    if turtle.storage[ i ] then
      local s = i .. ": " .. turtle.storage_names[ turtle.storage[ i ].type ]
      term.setCursorPos( w - #s, line_y )
      write( s )
      line_y = line_y + 1
    end
  end
end

function display_current_valid_fuel()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Refuel All - " )
  if turtle.refuel_all then
    print( "Full stack." )
  else
    print( "2 fuel item." )
  end

  local current_title = "- Current Valid Fuel -"
  term.setCursorPos( w - #current_title, 1 )
  print( current_title )
  local line_y = 2
  for k, v in pairs( turtle.valid_fuel ) do
    term.setCursorPos( w - #v, line_y )
    write( v )
    line_y = line_y + 1
  end
end

function display_current_forbidden_block()
  term.clear()
  local current_title = "- Current Forbidden Blocks -"
  term.setCursorPos( w - #current_title, 1 )
  print( current_title )
  local line_y = 2
  for k, v in pairs( turtle.forbidden_block ) do
    term.setCursorPos( w - #v, line_y )
    write( v )
    line_y = line_y + 1
  end
end

function show_set_storage_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Storage -" )
  print( "Here you can give a storage that maintain it's content when broken, like a ShulkerBox, to the turtle." )
  print( "To add a new storage, enter witch slot in the turtle's inventory it will be." )
  print()
  print( "Index: *Enter existing index to remove." )
  sleep( 0.2 )
  local input = read()
  local inventory_slot = tonumber( input )

  -- Check if need to remove
  local was_removed = false
  for k, v in pairs( turtle.storage ) do
    if k == inventory_slot then
      turtle.remove_storage_config( inventory_slot )
      was_removed = true
      break
    end
  end

  if not was_removed then
    term.clear()
    term.setCursorPos( 1, 1 )
    print( "What type is it?" )
    print( "1: The turtle will pick fuel from it." )
    print( "2: It will drop it's inventory in the storage when full." )
    print( "3: Filtered, can be used to drop item in a trash or a special storage." )
    print()
    print( "Type:" )
    sleep( 0.2 )
    input = read()
    local new_storage = { type = tonumber( input ) }

    if new_storage.type == 3 then
      term.clear()
      term.setCursorPos( 1, 1 )
      print( "Place the item to be filtered in the inventory and press enter.")
      sleep( 0.2 )
      input = read()
      new_storage.filtered_items = {}

      for i = 1, 16 do
        local item = turtle.getItemDetail( i )
        if item then
          table.insert( new_storage.filtered_items, item.name )
        end
      end
    end

    turtle.set_storage( inventory_slot, new_storage )
  end

  print( "Setup another storage? y, n")
  sleep( 0.2 )
  input = read()

  if input == "y" then
    show_set_storage_page()
  end

  menu.show()
end

function show_set_valid_fuel_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Valid Fuel -" )
  print( "A turtle can consume any fuel a furnace can burn." )
  print( "Enter the item name or place it in the first slot of the turtle's inventory then press enter." )
  print( "*same to remove it." )
  print()
  print( "Item name:" )
  sleep( 0.2 )
  local input = read()
  
  -- if the input is empty, try to get the first item name
  if input == "" then
    turtle.select( 1 )
    local item_data = turtle.getItemDetail()

    if item_data then
      input = item_data.name
    end
  end

  -- if input not empty, add the new item
  if input ~= "" then
    turtle.add_or_remove_valid_fuel( input )
  end

  display_current_valid_fuel()
  print( "Add another item? y, n")
  sleep( 0.2 )
  input = read()

  if input == "y" then
    show_set_valid_fuel_page()
  end

  menu.show()
end

function show_set_refuel_all_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Refuel All -" )
  print( "Do you want your turtle to eat a full stack of fuel when it needs it?" )
  print()
  print( "y, n" )
  sleep( 0.2 )
  local input = read()

  turtle.set_refuel_all( input == "y" )
  menu.show()
end

function show_set_forbidden_block_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Forbidden -" )
  print( "Blocks that the turtle should not mine! Used if you want to mine diamond ore with fortune or for stuff that can explode." )
  print( "Enter block name or place it in front of the turtle then press enter." )
  print( "*same to remove it." )
  sleep( 0.2 )
  local input = read()
  
  -- if the input is empty, try to get the block in front
  if input == "" then
    local has_block, block_data = turtle.inspect()

    if has_block then
      input = block_data.name
    end
  end

  -- if input not empty, add the new block
  if input ~= "" then
    turtle.add_or_remove_forbidden_block( input )
  end

  display_current_forbidden_block()
  print( "Add another block? y, n")
  sleep( 0.2 )
  input = read()

  if input == "y" then
    show_set_forbidden_block_page()
  end

  menu.show()
end

function refuel_all()
  turtle.refuel_all()
  menu.show()
end

function get_installer()
  shell.run( "pastebin run TBpm1C8V" )
end

function old_show_menu()
  -- Go to position
  if args[ 1 ] == "goto" then
    turtle.pathfind_to( vector.new( tonumber( args[ 2 ] ), tonumber( args[ 3 ] ), tonumber( args[ 4 ] ) ), false )
  -- setup a mine
  elseif args[ 1 ] == "setupMine" then
    miner:setup_mine( vector.new( tonumber( args[ 2 ] ), tonumber( args[ 3 ] ), tonumber( args[ 4 ] ) ) )
  -- start mining
  elseif args[ 1 ] == "mine" then
    miner:mine()
  end
end

local all_menu = {
  main_menu = {
    path = "Menu",
    prompt = "Choose an option:",
    parent = nil,
    options = {
      { key = "one", name = "1 - Stations", menu = "menu_stations" },
      { key = "two", name = "2 - Miner", menu = "menu_miner" }, 
      { key = "three", name = "3 - Builder", menu = "menu_builder" },
      { key = "four", name = "4 - Fleet Mode", menu = "menu_fleet" },
      { key = "five", name = "5 - Configurations", menu = "menu_config" },
      { key = "six", name = "6 - Refuel All", action = refuel_all }
    }
  },
  menu_stations = {
    path = "Menu -> Stations",
    prompt = "Choose a station:",
    parent = "main_menu",
    options = {
      { key = "one", name = "1 - Tree Farm", action = show_tree_farm_page },
      { key = "two", name = "2 - Cooking", action = smelter.start },
      { key = "three", name = "3 - Farming", menu = "menu_farms" }
    }
  },
  menu_farms = {
    path = "Menu -> Stations -> Farms",
    prompt = "Choose a farm:",
    parent = "menu_stations",
    options = {
      { key = "one", name = "1 - Farmer's Delight: Rice", action = harvester.rice_farm },
      { key = "two", name = "2 - Minecraft: Sugar Cane", action = show_cane_farm },
    }
  },
  menu_miner = {
    path = "Menu -> Miner",
    prompt = "Choose a job:",
    parent = "main_menu",
    options = {
      { key = "one", name = "1 - Dig Out", action = show_digout_page },
      { key = "two", name = "2 - Flatten chunk", action = show_flatten_chunk_page },
      { key = "three", name = "3 - Vein Mine", action = show_vein_mine_page },
      { key = "four", name = "4 - Branch Mining", action = show_branch_mining },
      { key = "five", name = "5 - Tunnel", action = miner.dig_tunnel }
    }
  },
  menu_builder = {
    path = "Menu -> Builder",
    prompt = "Choose a job:",
    parent = "main_menu",
    options = {
      { key = "one", name = "1 - Place Floor", action = builder.place_floor },
      { key = "two", name = "2 - Place Ceiling", action = start_place_ceiling },
      { key = "three", name = "3 - Place Wall", action = builder.place_wall }
    }
  },
  menu_fleet = {
    path = "Menu -> Fleet",
    prompt = "Choose a job:",
    parent = "main_menu",
    options = {
      { key = "one", name = "1 - Fleet Dig Out", action = show_fleet_digout_page },
      { key = "two", name = "2 - Fleet Flatten", action = show_fleet_flatten_page },
      { key = "three", name ="3 - Fleet Manager", action = show_fleet_manager_page }
    }
  },
  menu_config = {
    path = "Menu -> Settings",
    prompt = "Choose an option:",
    parent = "main_menu",
    options = {
      { key = "one", name = "1 - See Current Settings", action = show_current_config_page },
      { key = "two", name = "2 - Installer", action = get_installer },
      { key = "three", name = "3 - Storage", action = show_set_storage_page },
      { key = "four", name = "4 - Valid Fuel", action = show_set_valid_fuel_page },
      { key = "five", name = "5 - Refuel All", action = show_set_refuel_all_page },
      { key = "six", name = "6 - Forbidden Block", action = show_set_forbidden_block_page }
    }
  }
}

function on_key_pressed( key_name )
  -- test
  if key_name == "p" then
    turtle.drop_in_storage()
  end

  -- go back
  if current_menu.parent and key_name == "b" then
    display_menu( all_menu[ current_menu.parent ] )
  end

  -- sub menu or actions
  for i = 1, #current_menu.options do
    if current_menu.options[ i ] ~= nil and key_name == current_menu.options[ i ].key then
      -- sub menu
      if current_menu.options[ i ].menu ~= nil then
        display_menu( all_menu[ current_menu.options[ i ].menu ] )
        sleep( 0.1 )
        return
      -- action
      elseif current_menu.options[ i ].action ~= nil then
        current_menu.options[ i ].action()
        sleep( 0.1 )
        return
      end
    end
  end
end

menu = {
  show = function()
    display_menu( all_menu.main_menu )

    -- Timer to display time
    local clock_timer = os.startTimer( 1 )

    while true do
      event = { os.pullEvent() }
      -- is a key is pressed
      if event[ 1 ] == "key" then
        on_key_pressed( keys.getName( event[ 2 ] ) )
      elseif event[ 1 ] == "timer" and event[ 2 ] == clock_timer then
        clock_timer = os.startTimer( 1 )
      elseif event[ 1 ] == "modem_connected" then
        print( "modem_connected" )
      elseif event[ 1 ] == "rednet_message" then
        print( "rednet_message" )
      end
    end
  end
}

return menu