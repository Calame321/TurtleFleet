local ComponentBase = require( "turtlefleet.ui.components.component_base" )

---@class Label
---@field text string
---@field x integer
---@field y integer
---@field w integer
---@field h integer
---@field func table{ function, keys }
local Label = ComponentBase:inherit()
Label.__index = Label

--- Create a new label instance.
---@param self any
---@param text string
---@param x integer
---@param y integer
---@param w integer|nil
---@param h integer|nil
function Label.initialize( self, text, x, y, w, h )
  ComponentBase.initialize( self, x, y )
  self.text = text
  self.w = w or #text
  self.h = h or 1
  self.func = nil
end

function Label:set_parent( component )
  self.parent = component
  return self
end

function Label:set_text( text )
  self:draw_bg()
  if self.w == #self.text then self.w = #text end
  self.text = text
  self:draw()
  return self
end

function Label:draw_bg()
  term.setBackgroundColor( self.bg_color )
  term.setCursorPos( self:get_x(), self.y )
  paintutils.drawFilledBox( self:get_x(), self:get_y(), self.w + self:get_x() - 1, self.h + self:get_y() - 1, self.bg_color )
end

function Label:draw()
  -- The text color.
  local fg = self.fg_color
  -- Gray if disabled.
  if not self.enabled then
    fg = colors.lightGray
  end
  self:draw_bg()
  term.setTextColor( fg )
  -- Center the text.
  local start_pos_x = self:get_x() + ( ( self.w - #self.text ) / 2 )
  local start_pos_y = self:get_y() + ( self.h / 2 )
  term.setCursorPos( start_pos_x, start_pos_y )
  term.write( self.text )
  if self.components == nil then return end
  for _, c in ipairs( self.components ) do c:draw() end
  -- Draw highlight key.
  if self.func and self.func[ 2 ] then
    local upper_text = string.upper( self.text )
    for _, k in ipairs( self.func[ 2 ] ) do
      local key = string.char( k )
      for i = 1, #self.text do
        if upper_text:sub( i, i ) == key then
          term.setCursorPos( self:get_x() + i - 1, self:get_y() )
          local color = colors.pink
          -- Gray if disabled, else, lightBlue.
          if not self.enabled then
            color = colors.lightGray
          elseif self.fg_color ~= colors.cyan then
            color = colors.lightBlue
          end
          term.setTextColor( color )
          term.write( key )
          break
        end
      end
    end
  end
end

function Label:on_key( key )
  if not self.enabled or self.func == nil or self.func[ 2 ] == nil then return end
  for _, k in ipairs( self.func[ 2 ] ) do
    if k == key then self.func[ 1 ]() break end
  end
end

function Label:on_click( button, x, y )
  if self.func == nil then return end
  if button ~= 1 then return end
  if self:has_point( x, y ) then
    self.func[ 1 ]()
  end
end

function Label:set_func( func, activate_from_keys )
  self.func = { func, activate_from_keys }
  return self
end

function Label:remove_func()
  self.func = nil
  return self
end

return Label