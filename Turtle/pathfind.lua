--------------------
-- A* Pathfinding --
--------------------
pathfind = {}

pathfind.neibourgh_pos = {
    vector.new(  1,  0,  0 ),
    vector.new( -1,  0,  0 ),
    vector.new(  0,  1,  0 ),
    vector.new(  0, -1,  0 ),
    vector.new(  0,  0,  1 ),
    vector.new(  0,  0, -1 ),
}

function pathfind:reconstruct_path( cameFrom, current )
    total_path = { current }
    while came_from[ current ] do
        current = came_from[ current ]
        table.insert( total_path, 1, current )
    end
    return total_path
end

function pathfind:neibourgh( coord )
    local valid_n = {}

    for c = 1, #pathfind.neibourgh_pos do
        local n_coord = pathfind.neibourgh_pos[ c ] + coord
        local m = map_get( n_coord )

        if m == nil then
            table.insert( valid_n, n_coord )
        end
    end

    return valid_n
end

function pathfind:distance_to( v1, v2 )
    local v3 = v1 - v2
    return math.abs( v3.x ) + math.abs( v3.y ) + math.abs( v3.z )
end

function pathfind:get_lowest_f( openSet )
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
function pathfind:A_Star( start, goal )
    -- G = Distance from starting node.
    -- H = Distance from end node. ( distance_to( v1, v2 ) )
    -- F = G + H
    local openSet = { start } -- array
    local closedSet = {} -- array
    local came_from = {} -- dictionnary
    local gScore = {} -- dictionnary
    local fScore = {} -- dictionnary
    local sleep_counter = 0

    gScore[ start ] = 0
    fScore[ start ] = pathfind:distance_to( start, goal )

    while table.getn( openSet ) ~= 0 do
        -- avoid 'too long without yeilding'
        if sleep_counter == 30 then
            os.sleep( 0.05 )
            sleep_counter = 0
        end
        sleep_counter = sleep_counter + 1

        current = pathfind:get_lowest_f()

        if tostring( current ) == tostring( goal ) then
            return pathfind:reconstruct_path( came_from, current )
        end

        -- Adding current to closed set
        for o = 1, #openSet do
            if tostring( openSet[ o ] ) == tostring( current ) then
                table.insert( closedSet, current )
                table.remove( openSet, o )
                break
            end
        end

        local n = pathfind:neibourgh( current )

        -- Log the neibourgh
        local str_n = "Neibourgh: "
        for c = 1, #n do
            str_n = str_n .. tostring( n[ c ] ) .. " | "
        end

        for c = 1, #n do
            if not has_value( closedSet, n[ c ] ) then
                came_from[ n[ c ] ] = current
                gScore[ n[ c ] ] = gScore[ current ] + 1
                fScore[ n[ c ] ] = gScore[ n[ c ] ] + pathfind:distance_to( n[ c ], goal )

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

turtle.pathfind = pathfind