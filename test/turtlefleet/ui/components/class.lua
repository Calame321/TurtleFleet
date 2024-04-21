---@class Class Basic class implementation.
local Class = {}
Class.__index = Class

--- Used by other classes for inheritance.
---@return table sub_class
function Class:inherit()
  local sub_class = {}
  sub_class.__index = sub_class
  -- 'self' in this case is the parent class.
  sub_class.parent_init = self.initialize
  sub_class.parent_draw = self.draw
  setmetatable( sub_class, self )
  return sub_class
end

--- Sould be implemented in child classes.
---@param ... any Values to be initialized.
function Class:initialize( ... )
  error("this class cannot be initialized")
end

--- Sould be implemented in child classes.
function Class:draw()
  error("this class cannot draw")
end

--- Create a new instance of a class.
---@param ... any
---@return table
function Class:new( ... )
  local instance = {}
  -- 'self' is the class we're instantiating.
  setmetatable( instance, self )
  self.initialize( instance, ... )
  return instance
end

return Class