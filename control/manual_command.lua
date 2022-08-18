os.loadAPI( "connection.lua" )
shell.run( "TurtleFleet/Turtle/advanced_turtle.lua" )
json = dofile( "TurtleFleet/Utils/json.lua" )

local ws, err = http.websocket( connection.get_string() )

function string.tohex( str )
  return ( str:gsub( '.',
    function ( c )
      return string.format( '%02X', string.byte( c ) )
    end
  ) )
end

function string.fromhex( str )
  return ( str:gsub( '..',
    function ( cc )
      return string.char( tonumber( cc , 16 ) )
    end
  ) )
end

function decode( msg )
  local type = string.byte( string.sub( msg, 1, 1) )
  -- Bool
  if type == 0x01 then return msg:sub( 5, 5 ):byte() == 0x01
  -- Int
  elseif type == 0x02 then return tonumber( "0x" .. msg:sub( 5, 8 ):reverse():tohex() )
  -- String
  elseif type == 0x04 then return msg:sub( 9, 8 + tonumber( "0x" .. msg:sub( 5, 8 ):reverse():tohex() ) )
  -- 0x00 or unknown
  else return nil
  end
end

function connected()
  ws.send( "turtle" )
  ws.send( "001" .. json.encode( turtle.getInventory() ) )
end

local command = {}
command[ "moveForward" ] = function() turtle.forward() end
command[ "turnLeft" ] = function() turtle.turnLeft() end
command[ "turnRight" ] = function() turtle.turnRight() end
command[ "moveBack" ] = function() turtle.back() end
command[ "moveDown" ] = function() turtle.down() end
command[ "moveUp" ] = function() turtle.up() end
command[ "digUp" ] = function() turtle.digUp() end
command[ "digForward" ] = function() turtle.dig() end
command[ "digDown" ] = function() turtle.digDown() end
command[ "Connected" ] = connected

while true do
  local event, url, message = os.pullEvent( "websocket_message" )
  print( message )
  print( string.tohex( message ) )
  local data = decode( message )
  print( "Received = " .. tostring( data ) )

  if command[ tostring( data ) ] then
    command[ tostring( data ) ]()
  end
end