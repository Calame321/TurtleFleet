--[[
function show_fleet_flatten_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Fleet Flatten Chunk -" )
  print( "This will flatten an area the width of the number of turtle used." )
  print( "This turtle should be placed on a chest to the left." )
  print( "The length is given with a renamed piece of paper. (by step of 4) ex: '64'.")
  print( "Press enter for the chests placement.")
  sleep( 0.2 )
  read()
  print( "Chests (not needed if not in settings):" )
  print( "- Up: Fuel" )
  print( "- Down: Drop Storage" )
  print( "- Front: Turtle Storage" )
  print( "- Right: Filtered Storage" )
  print( "- Left: Buckets (if there is going to be lava)" )
  print()
  print( "Give a paper renamed with the length then press enter to start.")
  sleep( 0.2 )
  read()

  if has_flaten_fleet_setup() then
    fleet.flatten()
  else
    print( "The Fleet flatten setup is invalid." )
  end

  menu.show()
end
]]