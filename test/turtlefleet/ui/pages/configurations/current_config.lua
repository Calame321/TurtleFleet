--[[
function show_current_config_page()
  display_current_storage()
  term.setCursorPos( 1, h )
  write( "press enter." )
  sleep( 0.2 )
  read()

  display_current_valid_fuel()
  term.setCursorPos( 1, h )
  write( "press enter." )
  sleep( 0.2 )
  read()

  display_current_forbidden_block()
  term.setCursorPos( 1, h )
  write( "press enter." )
  sleep( 0.2 )
  read()

  menu.show()
end

function display_current_storage()
  term.clear()
  local current_title = "- current storage, slot: type -"
  term.setCursorPos( w - #current_title, 1 )
  print( current_title )
  local line_y = 2
  for i = 1, 16 do
    if turtle.storage[ i ] then
      local s = i .. ": " .. turtle.storage_names[ turtle.storage[ i ].type ]
      term.setCursorPos( w - #s, line_y )
      write( s )
      line_y = line_y + 1
    end
  end
end

function display_current_valid_fuel()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Refuel All - " )
  if turtle.refuel_all then
    print( "Full stack." )
  else
    print( "2 fuel item." )
  end

  local current_title = "- Current Valid Fuel -"
  term.setCursorPos( w - #current_title, 1 )
  print( current_title )
  local line_y = 2
  for k, v in pairs( turtle.valid_fuel ) do
    term.setCursorPos( w - #v, line_y )
    write( v )
    line_y = line_y + 1
  end
end

function display_current_forbidden_block()
  term.clear()
  local current_title = "- Current Forbidden Blocks -"
  term.setCursorPos( w - #current_title, 1 )
  print( current_title )
  local line_y = 2
  for k, v in pairs( turtle.forbidden_block ) do
    term.setCursorPos( w - #v, line_y )
    write( v )
    line_y = line_y + 1
  end
end
]]