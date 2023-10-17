--- A simple class in lua.
---@param super any
---@return table
function Class( super )
  local obj = {}
  obj.__index = obj
  setmetatable( obj, super )

  function obj.new( ... )
    local instance = setmetatable( {}, obj )
    if instance.ctor then instance:ctor( ... ) end
    return instance
  end

  return obj
end
