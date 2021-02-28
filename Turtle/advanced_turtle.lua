-----------------------------
-- global turtle functions --
-----------------------------
if not turtle then
    return
end

local valid_fuel = {
    "minecraft:charcoal",
    "minecraft:coal",
}

local DO_NOT_MINE = {
    "forbidden_arcanus:stella_arcanum",
    "minecraft:diamond_ore",
    "mysticalworld:amethyst_ore",
}

turtle.NORTH = 0
turtle.EAST = 1
turtle.SOUTH = 2
turtle.WEST = 3
turtle.LEFT = 4
turtle.RIGHT = 5

turtle.x = 0
turtle.y = 0
turtle.z = 0
turtle.dz = -1
turtle.dx = 0

if turtle.old_up == nil then
    turtle.old_turnRight = turtle.turnRight
    turtle.old_turnLeft =  turtle.turnLeft
    turtle.old_forward =   turtle.forward
    turtle.old_down =      turtle.down
    turtle.old_back =      turtle.back
    turtle.old_up =        turtle.up
end

function turtle.reverseDir( direction )
    if     direction == "forward" then return "back"
    elseif direction == "down"    then return "up"
    elseif direction == "back"    then return "forward"
    elseif direction == "up"      then return "down"
    end
    error( "turtle.reverseDir invalid direction!" )
end

function turtle.position()
    return vector.new( turtle.x, turtle.y, turtle.z )
end

function turtle.facing()
    if     turtle.dz == -1 and turtle.dx ==  0 then return turtle.NORTH
    elseif turtle.dz ==  0 and turtle.dx == -1 then return turtle.WEST
    elseif turtle.dz ==  0 and turtle.dx ==  1 then return turtle.EAST
    elseif turtle.dz ==  1 and turtle.dx ==  0 then return turtle.SOUTH
    end
    error( "turtle.facing invalid direction!" )
end

-- settings -- 
function turtle.load_position()
    local pos = settings.get( "position" )
    
    if pos then
        turtle.x = pos[ 1 ].x or 0
        turtle.y = pos[ 1 ].y or 0
        turtle.z = pos[ 1 ].z or 0
        turtle.dz = pos[ 2 ] or -1
        turtle.dx = pos[ 3 ] or 0
    end
end

function turtle.save_position()
    settings.set( "position", { { x = turtle.x, y = turtle.y, z = turtle.z }, turtle.dz, turtle.dx } )
    settings.save()
end

function turtle.set_position( x, y, z, dir )
    turtle.x = x
    turtle.y = y
    turtle.z = z

    if     dir == turtle.NORTH then turtle.dz = -1 turtle.dx =  0
    elseif dir == turtle.WEST  then turtle.dz =  0 turtle.dx = -1
    elseif dir == turtle.EAST  then turtle.dz =  0 turtle.dx =  1
    elseif dir == turtle.SOUTH then turtle.dz =  1 turtle.dx =  0
    end
    turtle.save_position()
end


--- Movement ---
-- Forward --
function turtle.forward()
    turtle.try_refuel()
    if not turtle.old_forward() then return false end
    turtle.x = turtle.x + turtle.dx
    turtle.z = turtle.z + turtle.dz
    turtle.save_position()
    return true
end

function turtle.wait_forward() while not turtle.forward() do os.sleep( 0.5 ) end end
function turtle.force_forward( block_to_break ) turtle.force_move( "forward", block_to_break ) end

-- Down --
function turtle.down()
    turtle.try_refuel()
    if not turtle.old_down() then return false end
    turtle.y = turtle.y - 1
    turtle.save_position()
    return true
end

function turtle.wait_down() while not turtle.down() do os.sleep( 0.5 ) end end
function turtle.force_down( block_to_break ) turtle.force_move( "down", block_to_break ) end

-- Back --
function turtle.back()
    turtle.try_refuel()
    if not turtle.old_back() then return false end
    turtle.x = turtle.x - turtle.dx
    turtle.z = turtle.z - turtle.dz
    turtle.save_position()
    return true
end

function turtle.wait_back() while not turtle.back() do os.sleep( 0.5 ) end end
function turtle.force_back( block_to_break ) turtle.force_move( "back", block_to_break ) end

-- Up --
function turtle.up()
    turtle.try_refuel()
    if not turtle.old_up() then return false end
    turtle.y = turtle.y + 1
    turtle.save_position()
    return true
end

function turtle.wait_up() while not turtle.up() do os.sleep( 0.5 ) end end
function turtle.force_up( block_to_break ) turtle.force_move( "up", block_to_break ) end

-- Move Direction --
function turtle.moveDir( direction )
    if     direction == "forward" then return turtle.forward()
    elseif direction == "down"    then return turtle.down()
    elseif direction == "back"    then return turtle.back()
    elseif direction == "up"      then return turtle.up()
    end
    error( "turtle.moveDir direction unknown!" )
end

-- Reverse --
function turtle.reverse( direction ) return turtle.moveDir( turtle.reverseDir( direction ) ) end
function turtle.force_reverse( direction ) turtle.force_move( turtle.reverseDir( direction ) ) end

function turtle.wait_move( direction )
    while not turtle.move( direction ) do
        os.sleep( 1 )
    end
end

-- Move --
function turtle.move( direction, block_to_break )
    turtle.try_refuel()
    local moved = turtle.moveDir( direction )
    if not moved and block_to_break and turtle.is_block_name( direction, block_to_break ) then
        turtle.digDir( direction )
        return turtle.moveDir( direction )
    end
    return moved
end

function turtle.force_move( direction, block_to_break )
    if direction ~= "back" then
        for b = 1, #DO_NOT_MINE do
            if turtle.is_block_name( direction, DO_NOT_MINE[ b ] ) then
                error( "I am scared of this " .. DO_NOT_MINE[ b ] )
            end
        end
    end

    while( not turtle.moveDir( direction ) ) do
        local s, d = turtle.inspectDir( direction )
        if s and string.find( d.name, "turtle" ) then
            os.sleep( 0.5 )
        elseif not block_to_break or turtle.is_block_name( direction, block_to_break ) then
            turtle.digDir( direction )
        end
    end
end

--- Turning ---
function turtle.turnRight()
    turtle.old_turnRight()
    local old_dx = turtle.dx
    turtle.dx = -turtle.dz
    turtle.dz = old_dx
    turtle.save_position()
    return true
end

function turtle.turnLeft()
    turtle.old_turnLeft()
    local old_dx = turtle.dx
    turtle.dx = turtle.dz
    turtle.dz = -old_dx
    turtle.save_position()
    return true
end

function turtle.turn180()
    if math.random ( 2 ) == 1 then
        turtle.turnLeft()
        turtle.turnLeft()
    else
        turtle.turnRight()
        turtle.turnRight()
    end
end

function turtle.turnDir( direction )
    if     direction == LEFT  then return turtle.turnLeft()
    elseif direction == RIGHT then return turtle.turnRight()
    end
    error( "turtle.turnDir invalid direction!" )
end

function turtle.turn( direction )
    local facing = turtle.facing()
    if facing == direction then
        return
    end

    if direction > 3 then
        turtle.turnDir( direction )
    else
        if math.abs( facing - direction ) == 2 then
            turtle.turn180()
        else
            if ( facing - direction ) % 4 == 1 then
                turtle.turnLeft()
            else
                turtle.turnRight()
            end
        end
    end
end

--- Dig ---
function turtle.digBack()
    turtle.turn180()
    turtle.dig()
    turtle.turn180()
end

function turtle.dig_all( direction ) while turtle.digDir( direction ) do sleep( 0.05 ) end end

function turtle.digDir( direction )
    if     direction == "forward"  then return turtle.dig()
    elseif direction == "up"       then return turtle.digUp()
    elseif direction == "down"     then return turtle.digDown()
    elseif direction == "back"     then return turtle.digBack()
    end
    error( "turtle.digDir invalid direction" )
end

-- Detect --
function turtle.detectBack()
    turtle.turn180()
    local success = turtle.detect()
    turtle.turn180()
    return success
end

function turtle.detectDir( direction )
    if     direction == "forward"  then return turtle.detect()
    elseif direction == "up"       then return turtle.detectUp()
    elseif direction == "down"     then return turtle.detectDown()
    elseif direction == "back"     then return turtle.detectBack()
    end
    error( "turtle.detectDir invalid direction!" )
end

-- Inspect --
function turtle.inspectBack()
    turtle.turn180()
    local success, data = turtle.inspect()
    turtle.turn180()
    return success, data
end

function turtle.inspectDir( direction )
    if     direction == "up"      then return turtle.inspectUp()
    elseif direction == "down"    then return turtle.inspectDown()
    elseif direction == "forward" then return turtle.inspect()
    elseif direction == "back"    then return turtle.inspectBack()
    end
    error( "inspectDir direction unknown!" )
end

-- Place --
function turtle.placeDir( direction )
    if     direction == "forward"  then return turtle.place()
    elseif direction == "up"       then return turtle.placeUp()
    elseif direction == "down"     then return turtle.placeDown()
    end
    error( "turtle.placeDir invalid direction" )
end

function turtle.wait_place() while not turtle.place() do os.sleep( 1 ) end end

-- Return succes and if false, the name of the block
function turtle.move_inspect( direction )
    if turtle.moveDir( direction ) then
        return true, nil
    end

    local s, d = turtle.inspectDir( direction )
    return false, d.name
end

function turtle.move_toward( destination )
    local distance = destination - turtle.position()

    if distance.x ~= 0 then
        if distance.x > 0 then turtle.turn( turtle.EAST ) else turtle.turn( turtle.WEST ) end
        return turtle.move_inspect( "forward" )
    end

    if distance.z ~= 0 then
        if distance.z > 0 then turtle.turn( turtle.SOUTH ) else turtle.turn( turtle.NORTH ) end
        return turtle.move_inspect( "forward" )
    end

    if distance.y ~= 0 then
        if distance.y > 0 then return turtle.move_inspect( "up" ) else return turtle.move_inspect( "down" ) end
    end

    return true
end

function turtle.dig_toward( destination )
    local distance = destination - turtle.position()

    if distance.x ~= 0 then
        if distance.x > 0 then turtle.turn( turtle.EAST ) else turtle.turn( turtle.WEST ) end
        return turtle.force_move( "forward" )
    end

    if distance.z ~= 0 then
        if distance.z > 0 then turtle.turn( turtle.SOUTH ) else turtle.turn( turtle.NORTH ) end
        return turtle.force_move( "forward" )
    end

    if distance.y ~= 0 then
        if distance.y > 0 then return turtle.force_move( "up" ) else return turtle.force_move( "down" ) end
    end

    return true
end

-- array of vector
function turtle.follow_path( path, can_dig )
    for i = 1, #path do
        if ( can_dig ) then
            turtle.dig_toward( path[ i ] )
        else
            local s, n = turtle.move_toward( path[ i ] )

            if not s then
                map_add( path[ i ], n )
                save_map()
                return false
            end
        end
    end

    return true
end

function turtle.pathfind_to( destination, can_dig )
    print( "Going to: " .. tostring( destination ) )
    local path = turtle.A_Star( turtle.position(), destination )
    
    while not follow_path( path, can_dig ) do
        print( "recalculating a path.")
        path = turtle.A_Star( turtle.position(), destination )
    end

    print( "ARRIVED !")
end

-- Inspect --
function turtle.is_block_name( direction, block_name )
    local s, d = turtle.inspectDir( direction )
    return s and d.name == block_name
end

function turtle.is_block_name_contains( direction, block_name )
    local s, d = turtle.inspectDir( direction )
    return s and string.find( d.name, block_name )
end

function turtle.is_block_tag( direction, tag )
    if direction == "back" then return false end
    if not turtle.detectDir( direction ) then return false end
    local success, data = turtle.inspectDir( direction )
    return success and data.tags[ tag ]
end

-- Inventory --
function turtle.getInventory()
    local inv = {}

    for i = 1, 16 do
        inv[ i ] = turtle.getItemDetail( i )
    end

    return inv
end

function turtle.get_item_index( name )
    for i = 1, 16 do
        local item = turtle.getItemDetail( i )
        if item and string.find( item.name, name ) then
            return i
        end
    end
    return -1
end

function turtle.has_items()
    for i = 1, 16 do
        if turtle.getItemCount( i ) > 0 then
            return true
        end
    end
    return false
end

function turtle.is_inventory_full()
    for i = 1, 16 do
        if turtle.getItemCount( i ) == 0 then
            return false
        end
    end
    return true
end

function turtle.drop_in_enderchest( stuff_to_keep )
    local enderchest_index = turtle.get_item_index( "enderstorage:ender_chest" )

    if enderchest_index == -1 then return end

    local to_keep = {}
    if stuff_to_keep then
        for k, v in pairs( stuff_to_keep ) do
            to_keep[ k ] = v
        end
    end

    turtle.dig_all( "up" )
    turtle.select( enderchest_index )
    while not turtle.placeUp() do
        os.sleep( 0.1 )
    end

    for i = 1, 16 do
        local item = turtle.getItemDetail( i )

        if item then
            print( item.name )
            print( to_keep[ item.name ] )
            if to_keep[ item.name ] and to_keep[ item.name ] > 0 then
                to_keep[ item.name ] = to_keep[ item.name ] - 1
            else
                turtle.select( i )
                -- wait to drop stuff if chest full
                if not turtle.dropUp() then while not turtle.dropUp() do os.sleep( 1 ) end end
            end
        end
    end

    turtle.select( 1 )
    turtle.digUp()
end

-- Fuel --
function turtle.get_valid_fuel_index()
    for i = 1, 16 do
        local item = turtle.getItemDetail( i )

        for f = 1, #valid_fuel do
            if item and string.find( item.name, valid_fuel[ f ] ) then
                return i
            end
        end
    end

    return -1
end

function turtle.is_valid_fuel( item_name )
    for f = 1, #valid_fuel do
        if item_name == valid_fuel[ f ] then
            return true
        end
    end

    return false
end

function turtle.try_refuel()
    if turtle.getFuelLevel() < 100 then
        local fuel_index = turtle.get_valid_fuel_index()

        if fuel_index == -1 then
            print( "Give me fuel please!" )
            print( "Valid fluel:" )

            for f = 1, #valid_fuel do
                print( valid_fuel[ f ] )
            end

            while fuel_index == -1 do
                os.sleep( 1 )
                fuel_index = turtle.get_valid_fuel_index()
            end
        end

        print( "Eating Some Fuel." )
        turtle.select( fuel_index )
        turtle.refuel( 2 )
    end
end

-- Job
function turtle.load_job()
    local f = fs.open( "job", "r" )
    if f then
        local job = f.readLine()
        if job == "treefarm" then
            local state = f.readLine()
            f.close()
            return job, tonumber( state )
        elseif job == "dig_out" then
            local depth_remaining = tonumber( f.readLine() )
            local width_start = tonumber( f.readLine() )
            local width_remaining = tonumber( f.readLine() )
            f.close()
            return job, depth_remaining, width_start, width_remaining
        end
    end

    return nil
end

function turtle.save_job( job, data1, data2, data3 )
    local f = fs.open( "job", "w" )
    f.writeLine( job )
    f.writeLine( data1 )
    if data2 then f.writeLine( data2 ) end
    if data3 then f.writeLine( data3 ) end
    f.flush()
    f.close()
end

turtle.load_position()