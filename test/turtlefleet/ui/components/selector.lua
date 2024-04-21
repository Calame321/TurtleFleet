local Input = require( "turtlefleet.ui.components.input" )

---@class Selector
---@field position_list { x: integer, y: integer }[]
---@field current_index integer
---@field changed function A function to call when the selection change.
---@field fg_color integer Arrow color when it's not focused.
---@field focus_color integer Arrow color when it's focused.
---@field has_focus boolean If the selector is movable.
local Selector = Input:inherit()
Selector.__index = Selector

local arrow_char = string.char( 26 )
local arrow_char2 = string.char( 16 )

function Selector.initialize( self )
  Input.initialize( self, 1, 1 )
  self.current_index = 1
  self.changed = function() end
  self.fg_color = colors.lightBlue
  self.focus_color = colors.cyan
  self.has_focus = false
end

function Selector.apply_focus( self, value )
  Input.apply_focus( self, value )
  self:draw()
end

function Selector:move_next()
  self.current_index = math.min( self.current_index + 1, #self.components )
  self.changed()
  self:draw()
end

function Selector:move_back()
  self.current_index = math.max( 1, self.current_index - 1 )
  self.changed()
  self:draw()
end

function Selector:on_changed( func )
  self.changed = func
  return self
end

function Selector:on_key( key )
  if self.has_focus then
    if key == keys.up then self:move_back() end
    if key == keys.down then self:move_next() end
    if key == keys.enter and self.components[ self.current_index ].func then self.components[ self.current_index ].func[ 1 ]() end
    for _, c in ipairs( self.components ) do
      if c.on_key then
        c:on_key( key )
      end
    end
  end
end

function Selector:on_click( button, x, y )
  for k, c in ipairs( self.components ) do
    if c.on_click then
      c:on_click( button, x, y )
    end
    if c:has_point( x, y ) then
      self.current_index = k
      self.changed()
      self:draw()
    end
  end
end

function Selector:clear()
  for _, v in ipairs( self.components ) do
    term.setCursorPos( v:get_x() - 1, v:get_y() + ( v.h / 2 ) )
    term.write( " " )
  end
end

function Selector:draw()
  local fg = self.fg_color
  if not self.enabled then fg = colors.lightGray end
  term.setBackgroundColor( self.bg_color )
  self:clear()
  self:parent_draw()
  local component = self.components[ self.current_index ]
  term.setCursorPos( component:get_x() - 1, component:get_y() + ( component.h / 2 ) )
  if self.has_focus then
    term.setTextColor( self.focus_color )
    term.write( arrow_char )
  else
    term.setTextColor( fg )
    term.write( arrow_char2 )
  end
end

function Selector:blink( state )
  if self.has_focus then
  term.setBackgroundColor( self.bg_color )
  local component = self.components[ self.current_index ]
    term.setCursorPos( component:get_x() - 1, component:get_y() + ( component.h / 2 ) )
    if state then term.setTextColor( self.focus_color ) else term.setTextColor( self.fg_color ) end
    term.write( arrow_char )
  end
end

return Selector