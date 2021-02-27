---------------
-- TREE FARM --
---------------
treefarm = station:new()
station = dofile( "TurtleFleet/Stations/station.lua" )

-- Tree Farm
treefarm.tree_farm_length = 15
treefarm.STATE = 0

treefarm.AT_START = 0
treefarm.IN_LANE = 1
treefarm.CUTTING = 2
treefarm.RETURNING = 3
treefarm.FURNACE = 4
treefarm.SETUP = 5

function treefarm:cut_tree()
    treefarm.STATE = treefarm.CUTTING
    turtle.save_job( "treefarm", treefarm.STATE )
    print( "Cutting a tree." )
    turtle.dig()
    turtle.forward()

    local height = 0

    while turtle.is_block_name_contains( "up", "log" ) do
        turtle.digUp()
        turtle.force_up()
        height = height + 1
    end

    for i = 0, height - 1 do
        turtle.force_down()
    end

    turtle.suck()
    turtle.force_back()
    turtle.suck()
    treefarm.STATE = treefarm.IN_LANE
    turtle.save_job( "treefarm", treefarm.STATE )
end


function treefarm:plant_trees()
    treefarm.STATE = treefarm.IN_LANE
    turtle.save_job( "treefarm", treefarm.STATE )
    print( "Planting trees." )

    for i = 0, treefarm.tree_farm_length do
        turtle.suck()
        turtle.force_forward()
        turtle.turnLeft()
        treefarm:inspect_tree()
        turtle.turn180()
        treefarm:inspect_tree()
        turtle.turnLeft()
    end

    turtle.suck()
    turtle.turn180()
    treefarm.STATE = treefarm.RETURNING
    turtle.save_job( "treefarm", treefarm.STATE )

    for i = 0, treefarm.tree_farm_length do
        turtle.suck()
        turtle.force_forward()
    end

    turtle.turn180()
    treefarm.STATE = treefarm.AT_START
    turtle.save_job( "treefarm", treefarm.STATE )
end


function treefarm:inspect_tree()
    local result, data = turtle.inspect()

    if result then
        if data.name == "minecraft:log" or data.tags[ "minecraft:logs" ] then
            treefarm:cut_tree()
        end
    end

    turtle.suck()

    if treefarm:has_sapling() then
        turtle.select( 1 )
        turtle.place()
    end
end


function treefarm:manage_furnace()
    local fuel_slot = turtle.get_valid_fuel_index()
    local coal_amount = 0
    if fuel_slot > 0 then
        coal_amount = turtle.getItemCount( fuel_slot )

        if coal_amount > 16 then return end
    end

    treefarm.STATE = treefarm.FURNACE
    turtle.save_job( "treefarm", treefarm.STATE )
    print( "Checking Furnace." )
    --inserting fuel
    turtle.turnRight()
    turtle.force_up()

    if fuel_slot > 0 then
        turtle.select( fuel_slot )
        turtle.drop( math.ceil( coal_amount / 2 ) )
    end

    -- inserting logs
    local has_log = false
    for n = 2, 16 do
        local nCount = turtle.getItemCount( n )
        
        if nCount > 0 then
            turtle.select( n )

            local item = turtle.getItemDetail()

            if string.find( item.name, "log" ) then
                has_log = true
                break
            end
		end
    end

    if has_log then
        turtle.force_up()
        turtle.force_forward()
        turtle.dropDown()
        turtle.back()
        turtle.down()
    end

    turtle.down()
    turtle.forward()
    turtle.select( 16 )
    turtle.suckUp()
    turtle.back()
    turtle.turnLeft()
    treefarm.STATE = treefarm.AT_START
    turtle.save_job( "treefarm", treefarm.STATE )
end


function treefarm:drop_stuff()
    print( "Unloading items." )
    turtle.turn180()

	for n = 2, 16 do
        local nCount = turtle.getItemCount( n )
        
        if nCount > 0 then
            local item = turtle.getItemDetail( n )

            if not turtle.is_valid_fuel( item.name ) then
                if string.find( item.name, "sapling" ) then
                    turtle.turnRight()
                    turtle.select( n )
                    turtle.drop()
                    turtle.turnLeft()
                elseif string.find( item.name, "stick" ) then
                    turtle.select( n )
                    turtle.refuel()
                else
                    turtle.select( n )
                    local can_drop = turtle.drop()

                    if not can_drop then
                        print( "Make some place in the chest!" )

                        while not turtle.drop() do
                            os.sleep( 30 )
                        end
                    end
                end
            end
		end
    end
    
    turtle.turn180()
end


function treefarm:has_sapling()
    local item = turtle.getItemDetail( 1 )
    local is_sapling = item and string.find( item.name, "sapling" )
    return is_sapling
end


function treefarm:refil_sapling()
    turtle.turnLeft()
    turtle.select( 1 )

    local amount = 64 - turtle.getItemCount( 1 )
    turtle.suck( amount )
    turtle.turnRight()
end


function treefarm:check_sapling()
    turtle.select( 1 )
    local item = turtle.getItemDetail( 1 )
    
    if item and not string.find( item.name, "sapling" ) then
        turtle.turn180()
        turtle.drop()
        turtle.turn180()
    end

    treefarm:refil_sapling()
end


function treefarm:has_tree_farm_setup()
    turtle.turnLeft()
    
    local success, data = turtle.inspect()

    if success and data.name == "minecraft:chest" then
        turtle.turnRight()
        return true
    end

    print( "Give me 2 chests, a furnace, some saplings and fuel please. Thank you!" )
    return false
end


function have_setup_materials()
    local has_chests = false
    local has_furnace = false
    local has_fuel = false
    local has_sapling = false

    for i = 1, 16 do
        local item = turtle.getItemDetail( i )

        if item then
            if item.name == "minecraft:chest" then
                if item.count == 2 then
                    has_chests = true
                end
            elseif item.name == "minecraft:furnace" then
                has_furnace = true
            elseif string.find( item.name, "sapling" ) then
                has_sapling = true
            elseif string.find( item.name, "coal" ) then
                has_fuel = true
            end
        end
    end

    return has_furnace and has_fuel and has_sapling and has_chests
end


function treefarm:setup_tree_farm()
    treefarm.STATE = treefarm.SETUP
    turtle.save_job( "treefarm", treefarm.STATE )
    while not have_setup_materials() do os.sleep( 1 ) end

    turtle.select( turtle.get_item_index( "coal" ) )
    turtle.transferTo( 16 )
    turtle.select( turtle.get_item_index( "minecraft:chest" ) )
    turtle.place()
    turtle.turnLeft()
    turtle.place()
    turtle.select( turtle.get_item_index( "minecraft:furnace" ) )
    turtle.turnLeft()
    turtle.up()
    turtle.place()
    turtle.down()
    turtle.turnLeft()
    turtle.select( turtle.get_item_index( "sapling" ) )
    turtle.transferTo( 1 )
    treefarm.STATE = treefarm.AT_START
    turtle.save_job( "treefarm", treefarm.STATE )
end


function treefarm:start_tree_farm( length )
    if length ~= nil then
        treefarm.tree_farm_length = length
    end
    
    turtle.set_position( 0, 0, 0, turtle.NORTH )

    print( "- Starting TREE FARM -" )
    if not treefarm:has_tree_farm_setup() then
        treefarm:setup_tree_farm()
    end

    while true do
        treefarm.STATE = treefarm.AT_START
        treefarm:check_sapling()
        treefarm:plant_trees()
        treefarm:manage_furnace()
        treefarm:drop_stuff()
        os.sleep( 10 )
    end
end

function treefarm:resume( state )
    if state == treefarm.AT_START then
        turtle.turn( turtle.NORTH )
    elseif state == treefarm.IN_LANE then
        return_home()
    elseif state == treefarm.CUTTING then
        while turtle.is_block_name_contains( "up", "log" ) do
            turtle.digUp()
            turtle.force_up()
        end
        while turtle.y ~= 0 do
            turtle.force_down()
        end
        turtle.force_back()
        return_home()
    elseif state == treefarm.RETURNING then
        return_home()
    elseif state == treefarm.FURNACE then
        if turtle.x == 1 and turtle.y == 2 and turtle.z == 0 then turtle.force_back() end
        if turtle.x == 0 and turtle.y == 2 and turtle.z == 0 then turtle.force_down() end
        if turtle.x == 0 and turtle.y == 1 and turtle.z == 0 then turtle.force_down() end
        if turtle.x == 1 and turtle.y == 0 and turtle.z == 0 then turtle.force_back() end
        turtle.turn( turtle.NORTH )
        treefarm:manage_furnace()
        treefarm:drop_stuff()
        treefarm:start_tree_farm()
    elseif state == treefarm.SETUP then
        treefarm:start_tree_farm()
    end

    print( 'End of resume' )
end

function return_home()
    turtle.turn( turtle.SOUTH )
    while turtle.z ~= 0 do
        turtle.force_forward()
    end
    turtle.turn( turtle.NORTH )
    treefarm:start_tree_farm()
end

return treefarm