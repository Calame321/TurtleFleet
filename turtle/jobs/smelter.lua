-------------
-- Coocker --
-------------
local coocking_time = 10
local coal_burn_time = 80

local furnace_fuel_ammount = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, }

function fill_inv()
  if not turtle.suck() then
    print( "The inventory is empty..." )

    while not turtle.suck() do
      sleep( 10 )
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
          sleep( 5 )
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
        turtle.select( turtle.get_item_index( "coal" ) )
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

function has_station()
  -- turn arround until it finds a chest
  for i = 1, 4 do
    turtle.turnRight()
    local has_block, data = turtle.inspect()
    if has_block then
      for k, v in pairs( data.tags ) do
        if k == "forge:chests" then
          -- turn 180 to see if there is a furnace
          turtle.turn180()
          has_block, data = turtle.inspect()

          if has_block and string.find( data.name, "furnace" ) then
            turtle.turnRight()
            return true
          end

          turtle.turn180()
        end
      end
    end
  end

  return false
end

function place_station()
  print( "Place 3 chests in slot 1" )
  print( "Place 16 furnaces in slot 2" )
  print( "And place some coal in my inventory." )
  print( "Then press enter.")
  read()

  -- Place chests
  turtle.turn180()
  turtle.select( 1 )
  turtle.turnRight()
  turtle.wait_place( "forward" )
  turtle.turnRight()
  turtle.wait_move( "back" )
  turtle.wait_place( "up" )
  turtle.wait_place( "down" )
  turtle.wait_move( "forward" )

  -- Place furnaces
  turtle.select( 2 )
  turtle.wait_move( "down" )
  turtle.turnRight()

  for i = 1, 16 do
    turtle.wait_move( "forward" )
    turtle.turnLeft()
    turtle.wait_place( "up" )
    turtle.turnRight()
  end

  -- return to start
  for i = 1, 16 do
    turtle.wait_move( "back" )
  end

  turtle.turnRight()
  turtle.wait_move( "up" )
end

local smelter = {
  start = function()
    term.clear()
    term.setCursorPos( 1, 1 )
    print( "- Start Cooking! -")
    turtle.up()

    if not has_station() then
      place_station()
    end

    while true do
      check_own_fuel()
      refuel_furnace()
      empty_furnace()
      insert_ingerdient()
      sleep( 80 )
    end
  end
}

return smelter