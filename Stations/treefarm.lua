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
    print( "Cutting a tree." )
    turtle.dig()
    turtle.forward()

    local height = 0

    while turtle.is_block_tag( "up", "minecraft:logs" ) do
        turtle.digUp()
        turtle.force_up( "minecraft:leaves" )
        height = height + 1
    end

    for i = 0, height - 1 do
        turtle.force_down( "minecraft:leaves" )
    end

    turtle.suck()
    turtle.back()
    turtle.suck()
    treefarm.STATE = treefarm.IN_LANE
end


function treefarm:plant_trees()
    treefarm.STATE = treefarm.IN_LANE
    print( "Planting trees." )

    for i = 0, treefarm.tree_farm_length do
        turtle.suck()
        turtle.force_forward( "minecraft:leaves" )
        turtle.turnLeft()
        treefarm:inspect_tree()
        turtle.turn180()
        treefarm:inspect_tree()
        turtle.turnLeft()
    end

    turtle.suck()
    turtle.turn180()
    treefarm.STATE = treefarm.RETURNING

    for i = 0, treefarm.tree_farm_length do
        turtle.suck()
        turtle.force_forward( "minecraft:leaves" )
    end

    turtle.turn180()
    treefarm.STATE = treefarm.AT_START
end


function treefarm:inspect_tree()
    local result, data = turtle.inspect()

    if result then
        if data.tags[ "minecraft:logs" ] then
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
    local coal_amount = turtle.getItemCount( fuel_slot )

    if coal_amount > 16 then return end

    treefarm.STATE = treefarm.FURNACE
    print( "Checking Furnace." )
    --inserting fuel
    turtle.force_up()
    turtle.turnRight()
    turtle.select( fuel_slot )
    turtle.drop( math.ceil( coal_amount / 2 ) )

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
end


function treefarm:start_tree_farm( length )
    treefarm.tree_farm_length = length or treefarm.tree_farm_length

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
        
    elseif state == treefarm.IN_LANE then

    elseif state == treefarm.CUTTING then

    elseif state == treefarm.RETURNING then

    elseif state == treefarm.FURNACE then

    elseif state == treefarm.SETUP then

    end
end

return treefarm