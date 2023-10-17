-------------
-- Farming --
-------------
local place_source_before = false
local cane_farm_size_row = 16
local cane_farm_size_col = 16

function place_source()
  turtle.select( 5 )
  turtle.digDown()
  turtle.placeDown( 1 )
  -- Refill the bucket.
  source_move( "forward" )
  turtle.empty_select( 3 )
  turtle.digDown()
  source_move( "forward" )
  turtle.empty_select( 4 )
  turtle.digDown()
  turtle.placeDown( 2 )
  source_move( "back" )
  turtle.placeDown( 1 )
  sleep( 0.5 )
  turtle.placeDown( 2 )
  turtle.placeDown( 3 )
  source_move( "forward" )
  turtle.placeDown( 4 )
end

function source_move( dir )
  if place_source_before then
    turtle.force_move( turtle.reverseDir( dir ) )
  else
    turtle.force_move( dir )
  end
end

function cane_farm()
  while true do
    turtle.force_forward()
    turtle.turnRight()

    for x = 1, 16 do
      for y = 1, 15 do
        if turtle.is_block_name( "down", "minecraft:sugar_cane" ) or
          turtle.is_block_name( "down", "minecraft:reeds" ) then turtle.digDown()
        end

        turtle.force_forward()
      end

      if turtle.is_block_name( "down", "minecraft:sugar_cane" ) or
        turtle.is_block_name( "down", "minecraft:reeds" ) then turtle.digDown()
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

        for i = 1, 16 do turtle.wait_forward() end

        turtle.turn180()

        local index = turtle.get_item_index( "sugar_cane" )
        if index == -1 then index = turtle.get_item_index( "minecraft:reeds" ) end
        while index > 0 do
          turtle.select( index )
          if not turtle.dropDown() then
            print( "The chest is full..." )
            read()
          end
          index = turtle.get_item_index( "sugar_cane" )
          if index == -1 then index = turtle.get_item_index( "minecraft:reeds" ) end
        end
      end
    end

    sleep( 222 )
  end
end

local harvester = {
  start_cane_farm = cane_farm,

  rice_farm = function()
    while true do
      turtle.forward()
      turtle.turnRight()

      for x = 1, 16 do
        for y = 1, 15 do
          local has_rice, rice = turtle.inspectDown()

          if has_rice and rice.state.age == 3 then turtle.digDown() end

          turtle.forward()
        end

        local has_rice, rice = turtle.inspectDown()
        if has_rice and rice.state.age == 3 then turtle.digDown() end

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

          for i = 1, 16 do turtle.forward() end

          turtle.turn180()

          local rice_index = turtle.get_item_index( "rice_panicle" )
          while rice_index > 0 do
            turtle.select( rice_index )
            if not turtle.dropDown() then
              print( "The chest is full..." )
              read()
            end
            rice_index = turtle.get_item_index( "rice_panicle" )
          end
        end
      end

      sleep( 120 )
    end
  end;

  -- Needs 2 buckets of water and 3 stacks of sugar canes.
  set_cane_farm = function()
    turtle.force_forward()
    turtle.turnRight()

    for col = 1, cane_farm_size_col do
      local start_row = 1 + ( ( ( col - 1 ) * 2 ) % 5 )
      local number_of_source = math.floor( ( cane_farm_size_row - ( start_row - 1 ) ) / 4 )

      local remaining_space = 0
      if col % 2 == 1 then
        remaining_space = cane_farm_size_row - ( ( ( number_of_source - 1 ) * 5 ) + start_row )
      else
        remaining_space = start_row - 2
      end

      -- place each source in the row.
      for s = 1, number_of_source do
        place_source_before = s == number_of_source and remaining_space < 2

        place_source()

        if not ( s == number_of_source ) then
          turtle.force_move_path( "fff" )
        end
      end

      -- If at the end.
      if col == cane_farm_size_col then
        local pos_in_col = 0
        if col % 2 == 1 then
          pos_in_col = start_row + ( ( number_of_source - 1 ) * 5 ) - 2
        else
          pos_in_col = start_row + 2
        end

        for i = 1, pos_in_col - 1 do
          turtle.force_forward()
        end
      else
        -- If there is space for a source further in the next col
        local path = ""
        if col % 2 == 1 then
          path = "lfl"
          if place_source_before then
            path = "b" .. path
          end
        else
          path = "rfr"
          if not place_source_before then
            path = "f" .. path
          end
        end
        turtle.force_move_path( path )
      end
    end

    turtle.force_move_path( "llu" )

    -- Place sugar cane!
    for col = 1, cane_farm_size_col do
      for row = 1, cane_farm_size_row do
        if col == cane_farm_size_col and row == cane_farm_size_row then
          break
        end

        local sugar_cane_index = turtle.get_item_index( "minecraft:sugar_cane" )
        while sugar_cane_index == -1 do
          print( "I need more sugar cane! (press enter after)" )
          read()

          sugar_cane_index = turtle.get_item_index( "minecraft:sugar_cane" )
        end

        turtle.placeDown( sugar_cane_index )

        if row ~= cane_farm_size_row then
          turtle.force_forward()
        end
      end

      -- Change column
      if col ~= cane_farm_size_col then
        if col % 2 == 1 then
          turtle.force_move_path( "rfr" )
        else
          turtle.force_move_path( "lfl" )
        end
      end
    end

    -- Place start chest.
    turtle.force_move_path( "rbu" )

    local chest_index = turtle.get_item_index( "minecraft:chest" )
    while chest_index == -1 do
      print( "I need a chest! You can replace it for another storage after I placed it. (press enter after)" )
      read()

      chest_index = turtle.get_item_index( "minecraft:chest" )
    end

    turtle.placeDown( chest_index )

    -- start farming!
    print( "Waiting for the sugar cane to grow, then I'll start working." )
    sleep( 240 )
    cane_farm()
  end;
}

return harvester