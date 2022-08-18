----------------
-- Networking --
----------------
Network = {}
Network.__index = Network

-- Constructor
function Network:new()
   local net = {}
   setmetatable( net, self )
   net.modem = nil
   return net
end

function Network:modemAdded( side )
  self.modem = side
end