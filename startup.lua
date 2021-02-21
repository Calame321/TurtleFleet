------------
-- Update --
------------
local git_path = "https://raw.githubusercontent.com/Calame321/TurtleFleet/main/"

function update_master()
    while turtle.suckDown( 1 ) do
        turtle.place()
        peripheral.call( "front", "turnOn" )

        local valid_signal = false

        while not valid_signal do
            os.pullEvent( "redstone" )

            if rs.getAnalogueInput( "front", 1 ) then
                valid_signal = true
            end
        end

        turtle.dig()
        turtle.dropUp()
    end

    turtle.forward()
    update()
end

function update()
    fs.delete( "startup" )
    fs.delete( "TurtleFleet" )
    get_file_from_github( git_path .. "Turtle/advanced_turtle.lua"  ,"TurtleFleet/Turtle/advanced_turtle.lua" )
    get_file_from_github( git_path .. "Turtle/pathfind.lua"         ,"TurtleFleet/Turtle/pathfind.lua" )
    get_file_from_github( git_path .. "Stations/station.lua"        ,"TurtleFleet/Stations/station.lua" )
    get_file_from_github( git_path .. "Stations/tree_farm.lua"      ,"TurtleFleet/Stations/treefarm.lua" )
    get_file_from_github( git_path .. "Jobs/job.lua"                ,"TurtleFleet/Jobs/job.lua" )
    get_file_from_github( git_path .. "Jobs/builder.lua"            ,"TurtleFleet/Jobs/builder.lua" )
    get_file_from_github( git_path .. "Jobs/cooker.lua"             ,"TurtleFleet/Jobs/cooker.lua" )
    get_file_from_github( git_path .. "startup.lua"                 ,"startup" )

    rs.setAnalogueOutput( "back", 1 )
    os.sleep( 0.05 )
    rs.setAnalogueOutput( "back", 0 )
end

function get_file_from_github( url, file_path )
    local f = fs.open( file_path, "w" )
    local w, m = http.get( url )
    if w then
        f.write( w.readAll() )
        f.flush()
        f.close()
    else
        print( "Cant load '" .. url .. "' : " .. m )
    end
end

local all_files = {
    "TurtleFleet/Turtle/advanced_turtle.lua",
    "TurtleFleet/Turtle/pathfind.lua",
    "TurtleFleet/Stations/station.lua",
    "TurtleFleet/Stations/treefarm.lua",
    "TurtleFleet/Jobs/job.lua",
    "TurtleFleet/Jobs/builder.lua",
    "TurtleFleet/Jobs/cooker.lua",
}

for i = 1, #all_files do
    if not fs.exists( all_files[ i ] ) then
        print( "Updating..." )
        update()
        print( "Updated! press a key to reboot" )
        read()
        os.reboot()
    end
end

------------
-- config --
------------
shell.run( "TurtleFleet/Turtle/advanced_turtle.lua" )
shell.run( "TurtleFleet/Turtle/pathfind.lua" )
station = dofile( "TurtleFleet/Stations/station.lua" )
treeFarm = dofile( "TurtleFleet/Stations/treefarm.lua" )
job = dofile( "TurtleFleet/Jobs/job.lua" )
builder = dofile( "TurtleFleet/Jobs/builder.lua" )
cooker = dofile( "TurtleFleet/Jobs/cooker.lua" )

-----------
-- Const --
-----------
local SIDES = redstone.getSides()

----------------------------
-- global helper function --
----------------------------

function mysplit( str, sep )
    if sep == nil then
        sep = "%s"
    end

    local t = {}

    for str in string.gmatch( str, "([^"..sep.."]+)" ) do
        table.insert(t, str)
    end

    return t
end

function has_value( table, val )
    for i = 1, #table do
        if tostring( table[ i ] ) == tostring( val ) then
            return true
        end
    end

    return false
end

--------------
-- Settings --
--------------
local map = {}

function load_settings()
    if not fs.exists( "map" ) then
        local file = fs.open( "map", "w" )
        file.close()
    end

    for line in io.lines( "map" ) do
        if line ~= "" then
            local l = mysplit( line )
            map_add( vector.new( l[ 1 ], l[ 2 ], l[ 3 ] ), l[ 4 ] )
        end
    end
end

function save_map()
    local file = fs.open( "map", "w" )

    for x, kx in pairs( map ) do
        for y, ky in pairs( kx ) do
            for z, kz in pairs( ky ) do
                file.writeLine( tostring( x ) .. " " .. tostring( y ) .. " " .. tostring( z ) .. " " .. kz )
            end
        end
    end

    file.flush()
    file.close()
end

---------
-- Map --
---------
function map_remove( pos )
    if not map[ pos.x ] or
       not map[ pos.x ][ pos.y ] or
       not map[ pos.x ][ pos.y ][ pos.z ] then
        return
    end

    table.remove( map[ pos.x ][ pos.y ], pos.z )
end

function map_add( pos, block_name )
    if not map[ pos.x ] then
        map[ pos.x ] = {}
    end

    if not map[ pos.x ][ pos.y ] then
        map[ pos.x ][ pos.y ] = {}
    end

    print( block_name .. " added for " .. tostring( pos ) )

    map[ pos.x ][ pos.y ][ pos.z ] = block_name
end

function map_get( pos )
    -- If a value is not set, return nil
    if not map[ pos.x ] or
       not map[ pos.x ][ pos.y ] or
       not map[ pos.x ][ pos.y ][ pos.z ] then
        return nil
    end

    return map[ pos.x ][ pos.y ][ pos.z ]
end



----------------
-- Decoration --
----------------

local initial_aditionnal_up = 5
local last_average_height = 10
local aditionnal_up = 5
local last_height = 0
local height = 0
local torch_counter = 0
local flat_stuff_to_keep = {}
flat_stuff_to_keep[ "minecraft:coal" ] = 1
flat_stuff_to_keep[ "minecraft:charcoal" ] = 1
flat_stuff_to_keep[ "minecraft:torch" ] = 1
flat_stuff_to_keep[ "minecraft:dirt" ] = 2


function flat_one()
    replace_for_dirt()
    height = 0
    last_height = 0

    dig_all_up()
    turtle.force_forward()
    turtle.force_forward()
    dig_all_up()

    -- change last height based on the height 
    if last_height < last_average_height then
        last_average_height = last_average_height - 1
    else
        last_average_height = last_height
    end

    for h = 1, height do
        turtle.force_down()
        turtle.dig()
    end

    turtle.force_back()
    replace_for_dirt()
    turtle.force_forward()
    replace_for_dirt()
    turtle.force_forward()
    replace_for_dirt()
end

function dig_all_up()
    -- dig up until no more block up or average height reached
    while must_go_up() do
        height = height + 1
        if turtle.detectUp() then
            last_height = height
        end
        turtle.dig()
        turtle.force_up()
    end
end


function must_go_up()
    if turtle.detect() or turtle.detectUp() or height < last_average_height then
        aditionnal_up = initial_aditionnal_up
        return true
    end

    if aditionnal_up > 0 then
        aditionnal_up = aditionnal_up - 1
        return true
    end

    aditionnal_up = initial_aditionnal_up
    return false
end

function replace_for_dirt()
    if not turtle.is_block_name( "down", "minecraft:grass_block" ) and not turtle.is_block_name( "down", "minecraft:dirt" ) then
        local dirt_index = turtle.get_item_index( "minecraft:dirt" )

        if dirt_index > 0 then
            turtle.select( dirt_index )
            turtle.digDown()
            turtle.placeDown()
            turtle.select( 1 )
        end
    end
end

function flaten_chunk()
    turtle.force_forward()
    turtle.turnRight()

    for x = 1, 16 do
        for y = 1, 4 do
            flat_one()
            
            if turtle.is_inventory_full() then
                turtle.drop_in_enderchest( flat_stuff_to_keep )
            end
            
            if y < 4 then turtle.force_forward() end
            flat_place_torch()
        end

        -- dont need to change row if at the end
        if x < 16 then
            if x % 2 == 0 then
                turtle.turnRight()
            else
                turtle.turnLeft()
            end

            turtle.force_forward()

            if x % 2 == 0 then
                turtle.turnRight()
            else
                turtle.turnLeft()
            end
        end
    end

    turtle.turnRight()
end

function flat_place_torch()
    -- Place a torch
    if torch_counter == 5 then
        torch_counter = 0

        local torch_index = turtle.get_item_index( "minecraft:torch" )

        if torch_index > 0 then
            turtle.select( torch_index )
            turtle.turn180()
            turtle.place()
            turtle.turn180()
            turtle.select( 1 )
        end
    else
        torch_counter = torch_counter + 1
    end
end

function flaten_chunks( number_of_chunk )
    for c = 1, number_of_chunk do
        flaten_chunk()
    end
end

-------------
-- Farming --
-------------
function rice_farm()
    while true do
        turtle.forward()
        turtle.turnRight()

        for x = 1, 16 do
            for y = 1, 15 do
                local has_rice, rice = turtle.inspectDown()

                if has_rice and rice.state.age == 3 then
                    turtle.digDown()
                end

                turtle.forward()
            end

            local has_rice, rice = turtle.inspectDown()
            if has_rice and rice.state.age == 3 then
                turtle.digDown()
            end

            -- dont need to change row if at the end
            if x < 16 then
                if x % 2 == 0 then
                    turtle.turnRight()
                    turtle.force_forward()
                    turtle.turnRight()
                else
                    turtle.turnLeft()
                    turtle.force_forward()
                    turtle.turnLeft()
                end
            else
                turtle.turnLeft()

                for i = 1, 16 do
                    turtle.forward()
                end

                turtle.turn180()

                local rice_index = get_item_index( "rice_panicle" )
                while rice_index > 0 do
                    turtle.select( rice_index )
                    if not turtle.dropDown() then
                        print( "The chest is full..." )
                        read()
                    end
                    rice_index = get_item_index( "rice_panicle" )
                end
            end
        end

        os.sleep( 120 )
    end
end

function cane_farm()
    while true do
        turtle.force_forward()
        turtle.turnRight()

        for x = 1, 16 do
            for y = 1, 15 do
                if turtle.is_block_name( "down", "minecraft:sugar_cane" ) then
                    turtle.digDown()
                end

                turtle.force_forward()
            end

            if turtle.is_block_name( "down", "minecraft:sugar_cane" ) then
                turtle.digDown()
            end

            -- dont need to change row if at the end
            if x < 16 then
                if x % 2 == 0 then
                    turtle.turnRight()
                    turtle.force_forward()
                    turtle.turnRight()
                else
                    turtle.turnLeft()
                    turtle.force_forward()
                    turtle.turnLeft()
                end
            else
                turtle.turnLeft()

                for i = 1, 16 do
                    turtle.wait_forward()
                end

                turtle.turn180()

                local index = get_item_index( "sugar_cane" )
                while index > 0 do
                    turtle.select( index )
                    if not turtle.dropDown() then
                        print( "The chest is full..." )
                        read()
                    end
                    index = get_item_index( "sugar_cane" )
                end
            end
        end

        os.sleep( 222 )
    end
end


----------------
-- Fleet Mode --
----------------
local flatten_length = 32
local is_last = false
local last_pos

function check_redstone_option()
    for s = 1, #SIDES do
        local redstone_option = rs.getAnalogueInput( SIDES[ s ] )

        if redstone_option == 7 then
            rs.setAnalogueOutput( "back", 7 )
            os.sleep( 0.1 )
            has_flaten_fleet_setup()
            rs.setAnalogueOutput( "back", 0 )
            fleet_flatten()
            return true
        elseif redstone_option == 6 then
            update()
            rs.setAnalogueOutput( "back", 1 )
            return true
        end
    end

    return false
end

function has_flaten_fleet_setup()
    local s, d = turtle.inspectUp()
    local has_chest_up = s and string.find( d.name, "chest" )
    s, d = turtle.inspectDown()
    local has_chest_down = s and string.find( d.name, "chest" )

    if has_chest_up and has_chest_down then
        for i = 1, 4 do
            s, d = turtle.inspect()
            local has_chest_front = s and string.find( d.name, "chest" )

            if has_chest_front then
                turtle.set_position( 0, 0, 0, NORTH )
                return true
            end

            turtle.turnLeft()
        end

        os.reboot()
    end

    return false
end

function fleet_flatten()
    turtle.suckUp()
    
    if not turtle.suck() then
        is_last = true
    end

    turtle.force_back()

    if is_last then
        local paper_index = turtle.get_item_index( "minecraft:paper" )
        if paper_index > 0 then
            local paper_detail = turtle.getItemDetail( paper_index, true )
            flatten_length = tonumber( paper_detail.displayName )
        end
    
    else
        place_mining_turtle()
    end

    turtle.turnLeft()
    goto_next_free_spot()
    turtle.turn180()
    
    if not is_last then
        wait_for_start_signal( "back", 10 )
    end

    rs.setAnalogueOutput( "front", 10 )
    os.sleep( 0.05 )
    rs.setAnalogueOutput( "front", 0 )
    turtle.turnRight()

    for y = 1, flatten_length / 4 do
        flat_one()
        --flat_empty_inventory()
        turtle.force_forward()
    end
end

function flat_empty_inventory()
    if turtle.is_inventory_full() then
        last_pos = turtle.position()
        turtle.pathfind_to( vector.new( 0, 0, 0 ), false )
    
        local has_fuel = false
        for i = 1, 16 do
            local item = turtle.getItemDetail( i )

            if item then
                if item.name == "minecraft:charcoal" then
                    turtle.select( i )
                    turtle.suckUp( 64 - item.count )
                else
                    turtle.select( i )
                    turtle.dropDown()
                end
            end
        end

        turtle.pathfind_to( last_pos, false )
    end
end

function wait_for_start_signal( direction, strength )
    local valid_signal = false

    while not valid_signal do
        os.pullEvent( "redstone" )

        if rs.getAnalogueInput( direction, strength ) then
            valid_signal = true
        end
    end
end

function goto_next_free_spot()
    local found_spot = false

    while not found_spot do
        local s, d = turtle.inspectDown()

        if s and string.find( d.name, "turtle" ) then
            turtle.force_forward()
        else
            turtle.force_down()
            found_spot = true
        end
    end
end


function place_mining_turtle()
    turtle.select( turtle.get_item_index( "computercraft:turtle" ) )
    turtle.place()
    rs.setAnalogueOutput( "front", 7 )
    
    local paper_index = turtle.get_item_index( "minecraft:paper" )
    if paper_index > 0 then
        local paper_detail = turtle.getItemDetail( paper_index, true )
        flatten_length = tonumber( paper_detail.displayName )
        turtle.select( paper_index )
        turtle.drop()
        turtle.select( 1 )
    end

    os.sleep( 0.05 )
    peripheral.call( "front", "turnOn" )
    wait_for_start_signal( "front", 7 )
    rs.setAnalogueOutput( "front", 0 )
    os.sleep( 0.10 )
end

----------
-- Menu --
----------
function show_menu()
    term.clear()
    load_settings()
    print( "What should I do ?" )
    print( "1 - Tree Farm. [optionnal -> farm length]" )
    print( "2 - Vein Mine. [block name]" )
    print( "3 - Dig Out. [depth width]" )
    print( "4 - Place Floor. [ 'up' for ceiling ]" )
    print( "5 - Place Wall." )
    print( "6 - Mine Branch." )
    print( "7 - Flatten 16 x 16. [chunks qty, xtra height]" )
    print( "8 - Start cooking." )
    print( "9 - branch mining." )
    print( "10 - Farm [ 1 = rice, 2 = sugar_cane ]" )
    local input = read()
    local args = mysplit( input )

    if args[ 1 ] == "pos" then
        turtle.set_position( tonumber( args[ 2 ] ), tonumber( args[ 3 ] ), tonumber( args[ 4 ] ), tonumber( args[ 5 ] ) )
    elseif args[ 1 ] == "goto" then
        turtle.pathfind_to( vector.new( tonumber( args[ 2 ] ), tonumber( args[ 3 ] ), tonumber( args[ 4 ] ) ), false )
    elseif args[ 1 ] == "setupMine" then
        miner:setup_mine( vector.new( tonumber( args[ 2 ] ), tonumber( args[ 3 ] ), tonumber( args[ 4 ] ) ) )
    elseif args[ 1 ] == "mine" then
        miner:mine()
    elseif args[ 1 ] == "update" then
        update_master()
    elseif args[ 1 ] == "1" then
        treeFarm.start_tree_farm()
    elseif args[ 1 ] == "2" then
        miner:vein_mine( "forward", args[ 2 ] )
    elseif args[ 1 ] == "3" then
        miner:dig_out( tonumber( args[ 2 ] ), tonumber( args[ 3 ] ) )
    elseif args[ 1 ] == "4" then
        builder:place_floor( args[ 2 ] )
    elseif args[ 1 ] == "5" then
        builder:place_wall()
    elseif args[ 1 ] == "6" then
        miner:mine_branch()
    elseif args[ 1 ] == "7" then
        local number_of_chunk = tonumber( args[ 2 ] )
        if number_of_chunk == nil then number_of_chunk = 1 end
        local extra_height = tonumber( args[ 3 ] )
        if extra_height ~= nil then
            last_average_height = extra_height
            initial_aditionnal_up = extra_height
        end
        if has_flaten_fleet_setup() then
            fleet_flatten()
        else
            flaten_chunks( number_of_chunk )
        end
    elseif args[ 1 ] == "8" then
        cooker:start_cooking()
    elseif args[ 1 ] == "9" then
        miner:branch_mining( args[ 2 ] )
    elseif args[ 1 ] == "10" then
        if args[ 2 ] == "1" then rice_farm() else cane_farm() end
    else
        print( "What?... bye." )
    end
end

-- Check if has redstone analog signal
if not check_redstone_option() then
    show_menu()
end