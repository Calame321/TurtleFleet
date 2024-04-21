local ComponentBase = require( "turtlefleet.ui.components.component_base" )

---@class Input
---@field has_focus boolean If the input component has te focus.
---@field focus_changed function
local Input = ComponentBase:inherit()
Input.__index = Input

--- A new input with focus off.
---@param self any
function Input.initialize( self, x, y )
  ComponentBase.initialize( self, x, y )
  self.has_focus = false
  self.focus_changed = function() end
end

--- Set the focus on the input.
---@param self any
---@param value boolean
---@return Input
function Input.set_focus( self, value )
  -- Wait a little so the input dosent leak to others.
  local co = coroutine.create( function() self:apply_focus( value ) end )
  table.insert( ComponentBase.coroutines, co )
  return self
end

--- Apply the focus a bit later to avoid the input to be applied to fast.
---@param self any
---@param value boolean
function Input.apply_focus( self, value )
  self.has_focus = value
  if self.focus_changed then
    self.focus_changed( value )
  end
end

function Input:on_focus_changed( func )
  self.focus_changed = func
  return self
end

return Input