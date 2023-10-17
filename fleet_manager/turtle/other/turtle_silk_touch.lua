--[[
Needed:
Pistons 2?
support blocks
]]

local piston_slot = 1
local sticky_piston_slot = 2
local support_slot = 3

  -- Must be 2 blocks away.
function pull_block( direction )
  turtle.select( sticky_piston_slot )
  if direction == "front" then turtle.place() else turtle.placeDown() end
  pulse( direction )
  if direction == "front" then turtle.dig() else turtle.digDown() end
  turtle.select( piston_slot )
end

function pulse( dir )
  rs.setOutput( dir, true )
  sleep( 0.1 )
  rs.setOutput( dir, false )
end

function pull_2_back()
  turtle.back()
  -- pull 2 back blocks.
  pull_block( "front" )
  turtle.forward()
  rs.setOutput( "front", true )
  turtle.select( piston_slot )
  turtle.dig()
  rs.setOutput( "front", true )
  pull_block( "front" )
  turtle.back()
  pull_block( "front" )
  turtle.down()
  turtle.forward()
  turtle.select( piston_slot )
  turtle.place()
  pulse( "front" )
end

function shift_left()
  turtle.turnLeft()
  turtle.forward()
  turtle.turnRight()
end

function shift_right()
  turtle.turnRight()
  turtle.forward()
  turtle.turnLeft()
end

turtle.down()
-- First push up.
turtle.forward()
turtle.select( support_slot )
turtle.placeDown()
turtle.back()
turtle.select( piston_slot )
turtle.place()
pulse( "front" )
-- pull 2 block.
turtle.up()
pull_2_back()
turtle.turnLeft()
turtle.forward()
turtle.turnRight()
turtle.forward()
turtle.turnRight()
turtle.up()
turtle.back()
-- Pull the row
pull_block( "front" )
shift_left()
pull_block( "front" )
shift_left()
pull_block( "front" )
turtle.forward()
turtle.turnRight()
turtle.forward()
turtle.forward()
rs.setOutput( "left", true )
turtle.forward()
rs.setOutput( "left", false )
turtle.turnLeft()
turtle.forward()
turtle.turnLeft()
pull_2_back()
turtle.dig()
turtle.turnLeft()
turtle.forward()
turtle.turnRight()
turtle.forward()
turtle.turnRight()
turtle.up()
-- Pull the row
pull_block( "front" )
shift_left()
pull_block( "front" )
shift_left()
pull_block( "front" )
turtle.back()
pull_block( "front" )
shift_right()
pull_block( "front" )
shift_right()
pull_block( "front" )
turtle.forward()
turtle.turnRight()
turtle.forward()
turtle.turnLeft()
turtle.forward()
turtle.turnLeft()
turtle.down()
turtle.select( piston_slot )
turtle.place()
pulse( "front" )
turtle.up()
pull_2_back()
turtle.dig()
