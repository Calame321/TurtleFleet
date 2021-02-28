------------
-- Miner --
------------

miner = job:new()

miner.chunk_per_region = 5 --from center
miner.branch_mine_length = 16 * miner.chunk_per_region

miner.stuff_to_keep = {}
miner.stuff_to_keep[ "minecraft:coal" ] = 2
miner.stuff_to_keep[ "minecraft:charcoal" ] = 2

function miner:vein_mine( from, block )
    -- up
    if turtle.is_block_name( "up", block ) then
        turtle.force_move( "up" )
        miner:vein_mine( "up", block )
    end

    -- forward
    if turtle.is_block_name( "forward", block ) then
        turtle.force_forward()
        miner:vein_mine( "forward", block )
    end

    -- down
    if turtle.is_block_name( "down", block ) then
        turtle.force_down()
        miner:vein_mine( "down", block )
    end
    
    -- left
    turtle.turnLeft()

    if turtle.is_block_name( "forward", block ) then
        turtle.force_forward()
        miner:vein_mine( "forward", block )
    end

    -- right
    turtle.turn180()
    
    if turtle.is_block_name( "forward", block ) then
        turtle.force_forward()
        miner:vein_mine( "forward", block )
    end

    turtle.turnLeft()
    turtle.reverse( from )
end

-------------
-- Dig Out --
-------------
miner.do_width_remaining = 0
miner.do_row_remaining = 0
miner.do_width_start = 0

function miner:dig_out_start( depth, width )
    turtle.set_position( 0, 0, 0, turtle.NORTH )
    turtle.force_forward()
    turtle.turnRight()
    do_width_remaining = width
    do_width_start = width
    do_row_remaining = depth
    turtle.save_job( "dig_out", do_row_remaining, do_width_start, do_width_remaining )
    miner:dig_out()
    fs.delete( "job" )
end

function miner:dig_out_resume( depth, width, remaining )
    do_row_remaining = depth
    do_width_start = width
    do_width_remaining = remaining
    if turtle.y > 0 then turtle.force_down() end
    if turtle.y < 0 then turtle.force_up() end
    miner:dig_out()
    fs.delete( "job" )
end

function miner:dig_out()
    while do_row_remaining ~= 0 do
        miner:dig_out_row()
        if do_row_remaining ~= 1 then
            miner:dig_out_change_row()
        else
            do_row_remaining = 0
        end
    end

    return_start()
end

function miner:dig_out_row()
    while do_width_remaining ~= 0 do
        turtle.dig_all( "up" )
        turtle.dig_all( "down" )

        local s, d = turtle.inspectUp()
        if s and d.name == "minecraft:lava" and d.state.level == 0 then turtle.force_up() turtle.force_down() end
        s, d = turtle.inspectDown()
        if s and d.name == "minecraft:lava" and d.state.level == 0 then turtle.force_down() turtle.force_up() end

        if turtle.is_inventory_full() then turtle.drop_in_enderchest( miner.stuff_to_keep ) end
        if do_width_remaining ~= 1 then turtle.force_forward() end

        do_width_remaining = do_width_remaining - 1
        turtle.save_job( "dig_out", do_row_remaining, do_width_start, do_width_remaining )
    end
end

function miner:dig_out_change_row()
    if turtle.x == 0 then turtle.turnRight() else turtle.turnLeft() end
    do_width_remaining = do_width_start
    do_row_remaining = do_row_remaining - 1
    turtle.force_forward()
    turtle.save_job( "dig_out", do_row_remaining, do_width_start, do_width_remaining )
    if turtle.x == 0 then turtle.turnRight() else turtle.turnLeft() end
end

function return_start()
    if turtle.x > 0 then
        turtle.turn( turtle.WEST )
        while turtle.x ~= 0 do turtle.force_forward() end
    end
    turtle.turn( turtle.NORTH )
    turtle.drop_in_enderchest()
end

-------------------
-- Branch Mining --
-------------------

function miner:check_ore( direction )
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
        miner:vein_mine( direction, ore_name )
    end

    return true
end

function miner:mine_branch()
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

function miner:empty_inventory()
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

function miner:branch_mining( side )
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

        miner:empty_inventory()
        branch_index = branch_index + 1
    end
end

local mining_state = "going_down"
local mine_start_position
local mine_level = 6
local mine_setup = false
local mine_layer = 1
local mine_direction = 0


function miner:setup_mine( mine_position )
    mine_start_position = mine_position
    save_mine()
end

function miner:get_mine_y()
    return ( mine_layer * 2 ) + 4
end

function miner:get_branch_entrance_pos( branch_index )
    local x = mine_start_position.x + ( ( ( ( mine_layer % 2 ) * 2 ) + 2 ) * ( mine_direction % 2 ) )
    local y = get_mine_y()
    local z = mine_start_position.z + ( ( ( ( mine_layer % 2 ) * 2 ) + 2 ) * ( ( 1 + mine_direction ) % 2 ) )
end

function miner:mine()
    miner:load_mine()

    if not mine_setup then
        print( "Need to setup the mine." )
        print( "My pos = " .. tostring( pos.coords ) )
        print( "Mine pos = " .. tostring( mine_start_position ) )
        go_to_mine_start()
        turtle.turn( turtle.NORTH )
        dig_mine_shaft()
        go_to_output_chest()
        turtle.turn( turtle.WEST )
        drop_inventory()
        mine_setup = true
        save_mine()
    end

    miner:go_to_mine_start()
    miner:go_down_the_mine()
    turtle.turn( mine_direction )
    miner:find_next_branch()
    --branch_mine()
end

function miner:find_next_branch()
    mining_state = "find_next_branch"
    local branch_index = 0

    while true do
        -- TODO: Force goto
        turtle.pathfind_to( miner:get_branch_entrance_pos( branch_index ), true )
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

function miner:go_to_mine_start()
    turtle.pathfind_to( mine_start_position, false )
end

function miner:go_to_output_chest()
    local mine_output_position = vector.new( mine_start_position.x, mine_start_position.y, mine_start_position.z - 1 )
    turtle.pathfind_to( mine_output_position, false )
end

function miner:dig_mine_shaft()
    turtle.turn( turtle.NORTH )
    for i = 1, 58 do
        turtle.force_move( "down" )
        turtle.dig()
    end
end

function miner:go_down_the_mine()
    mining_state = "going_down"
    miner:save_mine()
    local mine_level_position = vector.new( mine_start_position.x, 6, mine_start_position.z )
    turtle.pathfind_to( mine_level_position, false )
end

function miner:drop_inventory()
    mining_state = "drop_inventory"
    miner:save_mine()

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

function miner:load_mine()
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

function miner:save_mine()
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

return miner