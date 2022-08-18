----------------------
-- Computer Startup --
----------------------
function savePos( pos )
  settings.set( "pos", { face = pos.face, coords = pos.coords } )
  setting.save( ".settings" )
end

function onModemConnected()
  rednet.open( "top" )
  rednet.host( "tf", "main" )
end

function onNetMessage( event )
  if event[ 3 ] == "getJob" then
    rednet.send( event[ 2 ], "Scout" )
  end
end

function run()
  local posSetting = settings.get( "pos" )
  --local pos = Position:new()

  if posSetting ~= nil then
    pos:init( posSetting )
  end

  -- Timer to display time
  local clockTimer = os.startTimer( 1 )
  
  while true do
    event = { os.pullEvent() }
    if event[ 1 ] == "timer" and event[ 2 ] == clockTimer then
      clockTimer = os.startTimer( 1 )
    elseif event[ 1 ] == "modem_connected" then
      onModemConnected()
    elseif event[ 1 ] == "rednet_message" then
			onNetMessage( event )
    end

    term.clear()
    term.setBackgroundColor( colors.black )
  end
end