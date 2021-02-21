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
    get_file_from_github( git_path .. "Turtle/advanced_turtle.lua","TurtleFleet/Turtle/advanced_turtle.lua" )
    get_file_from_github( git_path .. "Stations/station.lua","TurtleFleet/Stations/station.lua" )
    get_file_from_github( git_path .. "Stations/tree_farm.lua","TurtleFleet/Stations/treefarm.lua" )
    get_file_from_github( git_path .. "startup.lua", "startup" )

    rs.setAnalogueOutput( "back", 1 )
    os.sleep( 0.05 )
    rs.setAnalogueOutput( "back", 0 )
end

function get_file_from_github( url, file_path )
    local f = fs.open( file_path, "w" )
    local w = http.get( url )
    f.write( w.readAll() )
    f.flush()
    f.close()
end

local all_files = {}
all_files[ 1 ] = "TurtleFleet/Turtle/advanced_turtle.lua"
all_files[ 2 ] = "TurtleFleet/Stations/station.lua"
all_files[ 3 ] = "TurtleFleet/Stations/treefarm.lua"

for i = 1, #all_files do
    if not fs.exists( all_files[ i ] ) then
        print( "Updating..." )
        update()
        os.reboot()
    end
end

------------
-- config --
------------
shell.run( "TurtleFleet/Turtle/advanced_turtle.lua" )
Station = dofile( "TurtleFleet/Stations/station.lua" )
TreeFarm = dofile( "TurtleFleet/Stations/treefarm.lua" )
json = dofile( "TurtleFleet/Utils/json.lua" )

-- region
local chunk_per_region = 5 --from center

-- Mining
local branch_mine_length = 16 * chunk_per_region

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

--function log( text )
    --local file = fs.open( "logs", "a" )
    --file.writeLine( text )
    --file.close()
--end

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

--------------------
-- A* Pathfinding --
--------------------
local openSet = { start }
local closedSet = {}
local came_from = {}
local gScore = {}
local fScore = {}
local sleep_counter = 0

local neibourgh_pos = {
    vector.new(  1,  0,  0 ),
    vector.new( -1,  0,  0 ),
    vector.new(  0,  1,  0 ),
    vector.new(  0, -1,  0 ),
    vector.new(  0,  0,  1 ),
    vector.new(  0,  0, -1 ),
}

function reconstruct_path( cameFrom, current )
    total_path = { current }
    while came_from[ current ] do
        current = came_from[ current ]
        table.insert( total_path, 1, current )
    end
    return total_path
end

function neibourgh( coord )
    local valid_n = {}

    for c = 1, #neibourgh_pos do
        local n_coord = neibourgh_pos[ c ] + coord
        local m = map_get( n_coord )

        if m == nil then
            table.insert( valid_n, n_coord )
        end
    end

    return valid_n
end

function distance_to( v1, v2 )
    local v3 = v1 - v2
    return math.abs( v3.x ) + math.abs( v3.y ) + math.abs( v3.z )
end

function get_lowest_f()
    local lowest_f = 9999999999;
    local lowest_node = nil

    for o = 1, #openSet do
        local node = openSet[ o ]
        local f = fScore[ node ]

        if f < lowest_f then
            lowest_f = f
            lowest_node = node
        end
    end

    return lowest_node
end

-- A* finds a path from start to goal.
function A_Star( start, goal )
    -- G = Distance from starting node.
    -- H = Distance from end node. ( distance_to( v1, v2 ) )
    -- F = G + H
    openSet = { start } -- array
    closedSet = {} -- array
    came_from = {} -- dictionnary
    gScore = {} -- dictionnary
    fScore = {} -- dictionnary

    gScore[ start ] = 0
    fScore[ start ] = distance_to( start, goal )

    while table.getn( openSet ) ~= 0 do
        -- avoid 'too long without yeilding'
        if sleep_counter == 20 then
            os.sleep( 0.05 )
            sleep_counter = 0
        end
        sleep_counter = sleep_counter + 1

        current = get_lowest_f()

        if tostring( current ) == tostring( goal ) then
            return reconstruct_path( came_from, current )
        end

        -- Adding current to closed set
        for o = 1, #openSet do
            if tostring( openSet[ o ] ) == tostring( current ) then
                table.insert( closedSet, current )
                table.remove( openSet, o )
                break
            end
        end

        local n = neibourgh( current )

        -- Log the neibourgh
        local str_n = "Neibourgh: "
        for c = 1, #n do
            str_n = str_n .. tostring( n[ c ] ) .. " | "
        end

        for c = 1, #n do
            if not has_value( closedSet, n[ c ] ) then
                came_from[ n[ c ] ] = current
                gScore[ n[ c ] ] = gScore[ current ] + 1
                fScore[ n[ c ] ] = gScore[ n[ c ] ] + distance_to( n[ c ], goal )

                if not has_value( openSet, n[ c ] ) then
                    table.insert( openSet, n[ c ] )
                end
            end
        end
    end

    -- Open set is empty but goal was never reached
    print( "No path found!" )
    return {}
end



----------------
-- Decoration --
----------------
function place_floor( direction )
    direction = direction or "down"
    print( "Place floor block in firt slot." )
    print( "Press a key when ready." )
    read()

    local floor_block = turtle.getItemDetail( 1 ).name
    local can_continue = true
    local rightTurn = true

    while can_continue do
        turtle.digDir( direction )
        
        local block_index = turtle.get_item_index( floor_block )

        if block_index == -1 then
            print( "Give me more block please!" )

            while block_index == -1 do
                os.sleep( 1 )
                block_index = turtle.get_item_index( floor_block )
            end
        end

        turtle.select( block_index )
        turtle.placeDir( direction )

        if not move( "forward", "minecraft:torch" ) or turtle.is_block_name( "down", floor_block ) then
            if rightTurn then
                turtle.turnRight()
            else
                turtle.turnLeft()
            end
            
            if not move( "forward", "minecraft:torch" ) then
                can_continue = false
            end

            if rightTurn then
                turtle.turnRight()
                rightTurn = false
            else
                turtle.turnLeft()
                rightTurn = true
            end
        end
    end
end


function place_wall()
    print( "Place floor block in firt slot." )
    print( "Press a key when ready." )
    read()

    local wall_block = turtle.getItemDetail( 1 ).name
    local direction = "up"

    while true do
        repeat
            turtle.try_refuel()
            turtle.dig_all( "forward" )
            turtle.select( get_item_index( wall_block ) )
            turtle.place()
            moveDir[ direction ]()
        until detectDir[ direction ]()

        turtle.dig_all( "forward" )
        turtle.select( get_item_index( wall_block ) )
        turtle.place()
        turtle.turnRight()

        if turtle.detect() then
            return
        end

        turtle.forward()
        turtle.turnLeft()

        if direction == "up" then
            direction = "down"
        else
            direction = "up"
        end
    end
end

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

------------
-- Mining --
------------
function vein_mine( from, block )
    -- up
    if turtle.is_block_name( "up", block ) then
        turtle.force_move( "up" )
        vein_mine( "up", block )
    end

    -- forward
    if turtle.is_block_name( "forward", block ) then
        turtle.force_forward()
        vein_mine( "forward", block )
    end

    -- down
    if turtle.is_block_name( "down", block ) then
        turtle.force_down()
        vein_mine( "down", block )
    end
    
    -- left
    turtle.turnLeft()

    if turtle.is_block_name( "forward", block ) then
        turtle.force_forward()
        vein_mine( "forward", block )
    end

    -- right
    turtle.turn180()
    
    if turtle.is_block_name( "forward", block ) then
        turtle.force_forward()
        vein_mine( "forward", block )
    end

    turtle.turnLeft()
    turtle.move_reverse( from )
end


function dig_out( depth, width )
    turtle.force_forward()
    turtle.turnRight()

    for x = 1, depth do
        for y = 1, width - 1 do
            turtle.dig_all( "up" )
            turtle.dig_all( "down" )
            turtle.force_forward()
        end

        turtle.dig_all( "up" )
        turtle.dig_all( "down" )
        
        -- dont need to change row if at the end
        if x < depth then
            if x % 2 == 0 then
                turtle.turnRight()
                turtle.force_forward()
                turtle.turnRight()
            else
                turtle.turnLeft()
                turtle.force_forward()
                turtle.turnLeft()
            end
            
            turtle.dig_all( "up" )
            turtle.dig_all( "down" )
        end
    end
end

function check_ore( direction )
    local ore_tag = "forge:ores"
    
    if turtle.is_block_tag( direction, ore_tag ) then
        local success, data = turtle.inspectDir( direction )
        local ore_name = data.name

        for b = 1, #DO_NOT_MINE do
            if ore_name == DO_NOT_MINE[ b ] then
                return false
            end
        end

        turtle.force_move( direction )
        vein_mine( direction, ore_name )
    end

    return true
end

function mine_branch()
    local found_forbidden_ore = false
    local depth = 0

    for i = 1, branch_mine_length do
        depth = depth + 1
        turtle.force_forward()

        if not check_ore( "up" ) then found_forbidden_ore = true end
        if not check_ore( "down" ) then found_forbidden_ore = true end
        turtle.turnLeft()
        if not check_ore( "forward" ) then found_forbidden_ore = true end
        turtle.turn180()
        if not check_ore( "forward" ) then found_forbidden_ore = true end
        turtle.turnLeft()

        if found_forbidden_ore then print( "FOUND DO_NOT_MINE ORE !!!!" ) break end
    end

    for i = 0, depth - 1 do
        turtle.force_move( "back" )

        if found_forbidden_ore then
            turtle.digDown()
        end
    end

    return found_forbidden_ore
end

function empty_inventory()
    for i = 1, 16 do
        local slot = turtle.getItemDetail( i )

        if slot and not turtle.is_valid_fuel( slot.name ) then
            turtle.select( i )
            
            if not turtle.drop() then
                print( "Please, make some place in the chest !!" )

                while not turtle.drop() do
                    os.sleep( 10 )
                end
            end
        end
    end
end

function branch_mining( side )
    local branch_index = 0

    for b = 1, branch_mine_length / 4 do
        turtle.turn180()

        for i = 1, ( branch_index * 4 ) do
            turtle.force_forward()
        end

        if side == "left" then turtle.turnLeft() else turtle.turnRight() end

        mine_branch()

        if side == "left" then turtle.turnLeft() else  turtle.turnRight() end
        
        for i = 1, ( branch_index * 4 ) do
            turtle.force_forward()
        end

        empty_inventory()
        branch_index = branch_index + 1
    end
end

local mining_state = "going_down"
local mine_start_position
local mine_level = 6
local mine_setup = false
local mine_layer = 1
local mine_direction = 0


function setup_mine( mine_position )
    mine_start_position = mine_position
    save_mine()
end

function get_mine_y()
    return ( mine_layer * 2 ) + 4
end

function get_branch_entrance_pos( branch_index )
    local x = mine_start_position.x + ( ( ( ( mine_layer % 2 ) * 2 ) + 2 ) * ( mine_direction % 2 ) )
    local y = get_mine_y()
    local z = mine_start_position.z + ( ( ( ( mine_layer % 2 ) * 2 ) + 2 ) * ( ( 1 + mine_direction ) % 2 ) )
end

function mine()
    load_mine()

    if not mine_setup then
        print( "Need to setup the mine." )
        print( "My pos = " .. tostring( pos.coords ) )
        print( "Mine pos = " .. tostring( mine_start_position ) )
        go_to_mine_start()
        turtle.turn( NORTH )
        dig_mine_shaft()
        go_to_output_chest()
        turtle.turn( WEST )
        drop_inventory()
        mine_setup = true
        save_mine()
    end

    go_to_mine_start()
    go_down_the_mine()
    turtle.turn( mine_direction )
    find_next_branch()
    --branch_mine()
end

function find_next_branch()
    mining_state = "find_next_branch"
    local branch_index = 0

    while true do
        -- TODO: Force goto
        turtle.pathfind_to( get_branch_entrance_pos( branch_index ), true )
        turtle.turn( LEFT )

        local s, d = turtle.inspect()

        if ( not s or d.name ~= "minecraft:cobblestone" ) then
            return true
        end

        turtle.turn( RIGHT )
        branch_index = branch_index + 1

        if branch_index * 4 >= branch_mine_length then
            return false
        end
    end  

    return false
end

function go_to_mine_start()
    turtle.pathfind_to( mine_start_position, false )
end

function go_to_output_chest()
    local mine_output_position = vector.new( mine_start_position.x, mine_start_position.y, mine_start_position.z - 1 )
    turtle.pathfind_to( mine_output_position, false )
end

function dig_mine_shaft()
    turtle.turn( NORTH )
    for i = 1, 58 do
        turtle.force_move( "down" )
        turtle.dig()
    end
end

function go_down_the_mine()
    mining_state = "going_down"
    save_mine()
    local mine_level_position = vector.new( mine_start_position.x, 6, mine_start_position.z )
    turtle.pathfind_to( mine_level_position, false )
end

function drop_inventory()
    mining_state = "drop_inventory"
    save_mine()

    for i = 1, 16 do
        local item = turtle.getItemDetail( i )
        if item and item.count > 0 then
            turtle.select( i )

            if item.name == "minecraft:coal" or item.name == "minecraft:charcoal" then
                turtle.dropUp()
            else
                local chest_has_place = turtle.drop()

                while not chest_has_place do
                    os.sleep( 5 )
                    chest_has_place = turtle.drop()
                end
            end
        end
    end

    turtle.select( 1 )
    turtle.suckUp()
end

function load_mine()
    if not fs.exists( "mine" ) then
        local file = fs.open( "mine", "w" )
        file.close()
    end

    local file = fs.open( "mine", "r" )
    mining_state = file.readLine()
    local start_pos_split = mysplit( file.readLine() )
    mine_start_position = vector.new( start_pos_split[ 1 ], start_pos_split[ 2 ], start_pos_split[ 3 ] )
    mine_level = tonumber( file.readLine() )
    mine_setup = "true" == file.readLine()
    mine_layer = tonumber( file.readLine() )
end

function save_mine()
    local file = fs.open( "mine", "w" )
    file.writeLine( mining_state )
    print( "Save mine pos: " .. tostring( mine_start_position ) )
    file.writeLine( tostring( mine_start_position.x ) .. " " .. tostring( mine_start_position.y ) .. " " .. tostring( mine_start_position.z ) )
    file.writeLine( tostring( mine_level ) )
    file.writeLine( tostring( mine_setup ) )
    file.writeLine( tostring( mine_layer ) )
    file.flush()
    file.close()
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

--------------
-- Coocking --
--------------
local coocking_time = 10
local coal_burn_time = 80

local furnace_fuel_ammount = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, }

function fill_inv()
    if not turtle.suck() then
        print( "The inventory is empty..." )

        while not turtle.suck() do
            os.sleep( 60 )
        end
    end


    while turtle.suck() do end

    local item_in_inv = 0
    for i = 1, 16 do
        item_in_inv = item_in_inv + turtle.getItemCount( i )
    end

    turtle.drop( item_in_inv % 16 )
    return math.floor( item_in_inv / 16 )
end

function drop_remaining_items()
    if turtle.has_items() then
        for i = 1, 16 do
            if turtle.getItemCount( i ) > 0 then
                turtle.select( i )
                while not turtle.drop() do
                    os.sleep( 5 )
                end
            end
        end
    end
end

function refuel_furnace()
    turtle.turnLeft()
    turtle.select( 1 )
    turtle.suck()

    local need_refuel = turtle.getItemCount( 1 ) < 32
    turtle.drop()

    if need_refuel then
        print( "Refuelling the furnaces.")
        turtle.turn180()
        turtle.select( 1 )

        -- suck all the fuel possible
        local fuel_to_transfer = fill_inv()

        if each_fuel == 0 then
            error( "Not enough fuel !" )
        end

        turtle.turnLeft()
        turtle.forward()
        turtle.turnLeft()

        for i = 1, 16 do
            turtle.forward()
            turtle.turnLeft()
            
            for a = 1, 2 do
                turtle.select( get_item_index( "coal" ) )
                turtle.transferTo( 16 )
            end

            turtle.select( 16 )
            turtle.drop( fuel_to_transfer )
            turtle.turnRight()
        end

        for i = 1, 16 do
            turtle.back()
        end

        turtle.turnRight()
        turtle.back()

        turtle.turnRight()
        drop_remaining_items()
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
end

function insert_ingerdient()
    turtle.up()
    turtle.select( 1 )
    local item_to_insert = fill_inv()
    local item = turtle.getItemDetail()
    turtle.turnLeft()
    
    for i = 1, 16 do
        turtle.forward()
        for x = 1, 16 do
            if turtle.getItemCount( x ) > 0 then
                turtle.select( x )
                turtle.dropDown( item_to_insert )
            end
        end
    end

    for i = 1, 16 do
        turtle.back()
    end

    turtle.turnRight()
    drop_remaining_items()
    turtle.down()
end

function empty_furnace()
    turtle.down()
    turtle.turnLeft()
    
    for i = 1, 16 do
        turtle.forward()
        turtle.select( 1 )
        turtle.suckUp()
    end

    for i = 1, 16 do
        turtle.back()
    end

    turtle.turnRight()
    drop_remaining_items()
    turtle.up()
end

function check_own_fuel()
    if turtle.getFuelLevel() < 500 then
        turtle.turnRight()
        turtle.suck()
        turtle.refuel()
        turtle.turnLeft()
    end
end

function start_cooking()
    while true do
        check_own_fuel()
        refuel_furnace()
        empty_furnace()
        insert_ingerdient()
        os.sleep( 80 )
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
    elseif args[ 1 ] == "flatone" then
        flat_one()
    elseif args[ 1 ] == "goto" then
        turtle.pathfind_to( vector.new( tonumber( args[ 2 ] ), tonumber( args[ 3 ] ), tonumber( args[ 4 ] ) ), false )
    elseif args[ 1 ] == "setupMine" then
        setup_mine( vector.new( tonumber( args[ 2 ] ), tonumber( args[ 3 ] ), tonumber( args[ 4 ] ) ) )
    elseif args[ 1 ] == "mine" then
        mine()
    elseif args[ 1 ] == "update" then
        update_master()
    elseif args[ 1 ] == "1" then
        TreeFarm.start_tree_farm()
    elseif args[ 1 ] == "2" then
        vein_mine( "forward", args[ 2 ] )
    elseif args[ 1 ] == "3" then
        dig_out( tonumber( args[ 2 ] ), tonumber( args[ 3 ] ) )
    elseif args[ 1 ] == "4" then
        place_floor( args[ 2 ] )
    elseif args[ 1 ] == "5" then
        place_wall()
    elseif args[ 1 ] == "6" then
        mine_branch()
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
        start_cooking()
    elseif args[ 1 ] == "9" then
        branch_mining( args[ 2 ] )
    elseif args[ 1 ] == "10" then
        if args[ 2 ] == "1" then
            rice_farm()
        else
            cane_farm()
        end
    else
        print( "What?... bye." )
    end
end

-- Check if has redstone analog signal
if not check_redstone_option() then
    show_menu()
end