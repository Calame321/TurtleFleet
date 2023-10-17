-- Meta class
Task = {
  id = 0,
  status = "ready",
  type = "building",
  position = nil,
  parameters = nil
}

-- Derived class method new
function Task:new( type )
  local t = {}
  setmetatable( t, self )
  self.__index = self
  t.id = math.random( 9999 )
  t.status = "ready"
  t.type = type or "building"
  t.position = nil
  t.parameters = {}
  return t
end

return Task