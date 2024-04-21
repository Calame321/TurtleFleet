--[[
function show_fleet_manager_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Fleet Manager -" )
  print( "This option will build the Fleet Manager system." )
  print( "It will manage the turtle by itself. You'll give your command trought the computer." )
  print( "You wont be able to control the turtles that are assigned to it.")
  print( "Press a key to continue." )
  sleep( 0.2 )
  read()
  print()
  print( "The turtle will claim this chunk, so it should be started outside in the overworld.")
  print()
  print( "Press a key for the list of material needed.")
  sleep( 0.2 )
  read()
  print( "Material:" )
  print( "- 64 Coal/Charcoal" )
  print( "- 1 Chest. (or other storage block)" )
  print( "- 4 Computer. (at least 1 advanced" )
  print( "- 5 Wireless Modem. (4 Ender Modem if possible)" )
  print( "- 1 Disk Drive" )
  print( "- 1 Disk" )
  print( "- 1 Crafting Table")
  print( "- 1 Diamond Pickaxe. (If the turtle dosen't have one)")
  print()
  sleep( 0.2 )
  read()
  print()
  print( "What is my position:" )
  print( "x = ?" )
  sleep( 0.2 )
  local x = tonumber( read() )
  print( "y = ?" )
  local y = tonumber( read() )
  print( "z = ?" )
  local z = tonumber( read() )
  print()
  print( "What direction am I facing?" )
  print( "1 - North" )
  print( "2 - East" )
  print( "3 - South" )
  print( "4 - West" )
  local facing = tonumber( read() )

  turtle.x = x
  turtle.y = y
  turtle.z = z
  if facing == "1" then turtle.dz = -1
  elseif facing == "2" then turtle.dx = 1
  elseif facing == "3" then turtle.dz = 1
  elseif facing == "4" then turtle.dx = -1
  end

  -- Get the chunk position.
  -- Place the computers and modems.
  -- Place the chest, put the crafting table inside.
  -- Place the drive and disk.
  -- Install the startup on the disk.
  -- Boot the computer.
  -- Reboot to install the fleet_manager for the turtle.

  menu.show()
end
]]