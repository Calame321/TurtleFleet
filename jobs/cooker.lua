--------------
-- Coocker --
--------------
cooker = job:new()

local coocking_time = 10
local coal_burn_time = 80

local furnace_fuel_ammount = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, }

function cooker:fill_inv()
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

function cooker:drop_remaining_items()
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

function cooker:refuel_furnace()
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
        cooker:drop_remaining_items()
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
end

function cooker:insert_ingerdient()
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
    cooker:drop_remaining_items()
    turtle.down()
end

function cooker:empty_furnace()
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
    cooker:drop_remaining_items()
    turtle.up()
end

function cooker:check_own_fuel()
    if turtle.getFuelLevel() < 500 then
        turtle.turnRight()
        turtle.suck()
        turtle.refuel()
        turtle.turnLeft()
    end
end

function cooker:start_cooking()
    while true do
        cooker:check_own_fuel()
        cooker:refuel_furnace()
        cooker:empty_furnace()
        cooker:insert_ingerdient()
        os.sleep( 80 )
    end
end

return cooker