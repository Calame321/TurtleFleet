local o = {}

--- Check all event received to distribute them.
function o.check_events()
  while true do
    -- Get the rednet message event.
    local event = { os.pullEvent() }
    if event[ 1 ] == "rednet_message" then
      CNetworkManager.received_message( event[ 2 ], event[ 3 ], event[ 4 ] )
    end
  end
end

return o