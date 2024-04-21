
--[[
function show_cane_farm()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Sugar Cane Farm -" )
  print( "Do you want me to build the farm?")
  print( "y, n? (default = no)")
  sleep( 0.2 )
  local input = read()

  if input == "y" then
    print( "Give me 2 water buckets, in slot 1 and 2. I'll also need 3 stacks of sugar cane and a chest." )
    print( "Press enter to start." )
    read()
    harvester.set_cane_farm()
  else
    harvester.start_cane_farm()
  end
end
]]