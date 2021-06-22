--------------
-- Position --
--------------

Position = {}
Position.__index = Position

-- Constructor
function Position:new()
   local pos = {}
   setmetatable( pos, self )
   pos.facing = 0
   pos.coords = vector.new( 0, 0, 0 )
   return pos
end

function Position:init( pos )
    self.facing = pos.face
    self.coords = pos.coords
end