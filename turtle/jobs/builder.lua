-------------
-- Builder --
-------------
local builder = {
  place_floor = function( direction )
    direction = direction or "down"
    term.clear()
    term.setCursorPos( 1, 1 )
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
  
      if not turtle.move( "forward", "minecraft:torch" ) or turtle.is_block_name( "down", floor_block ) then
        if rightTurn then turtle.turnRight() else turtle.turnLeft() end
        if not turtle.move( "forward", "minecraft:torch" ) then can_continue = false end
  
        if rightTurn then
          turtle.turnRight()
          rightTurn = false
        else
          turtle.turnLeft()
          rightTurn = true
        end
      end
    end
  end;
  
  place_wall = function()
    term.clear()
    term.setCursorPos( 1, 1 )
    print( "Place floor block in first slot." )
    print( "Press a key when ready." )
    read()
  
    local wall_block = turtle.getItemDetail( 1 ).name
    local direction = "up"
  
    while true do
      repeat
        turtle.try_refuel()
        turtle.dig_all( "forward" )
        turtle.select( turtle.get_item_index( wall_block ) )
        turtle.place()
        turtle.moveDir( direction )
      until turtle.detectDir( direction )
  
      turtle.dig_all( "forward" )
      turtle.select( turtle.get_item_index( wall_block ) )
      turtle.place()
      turtle.turnRight()
  
      if turtle.detect() then return end
  
      turtle.forward()
      turtle.turnLeft()
  
      if direction == "up" then direction = "down" else direction = "up" end
    end
  end
}

return builder