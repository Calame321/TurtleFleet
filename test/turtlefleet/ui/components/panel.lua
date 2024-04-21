local ComponentBase = require( "turtlefleet.ui.components.component_base" )

---@class Panel
---@field title string
---@field has_border boolean
---@field border_color integer Color of the border.
local Panel = ComponentBase:inherit()
Panel.__index = Panel

local VERTICAL_BAR = string.char( 149 )
local LEFT_BAR = string.char( 149 )
local RIGHT_BAR = string.char( 149 )
local BOTTOM_BAR = string.char( 131 )
local LEFT_CORNER = string.char( 130 )
local RIGHT_CORNER = string.char( 129 )

--- Create a panel with a border excluded from the size.
---@param self any
---@param x integer
---@param y integer
---@param w integer
---@param h integer
function Panel.initialize( self, x, y, w, h )
  ComponentBase.initialize( self, x, y )
  self.w = w or 10
  self.h = h or 10
  self.has_border = false
  self.border_color = colors.lightGray
  self.title = ""
end

function Panel:set_color( color )
  self.border_color = color
  return self
end

function Panel:border( value )
  self.has_border = value
  return self
end

function Panel:set_title( title )
  self.title = title
  return self
end

function Panel.draw( self )
  paintutils.drawFilledBox( self:get_x(), self:get_y(), self.w, self.h, colors.white )
  term.setTextColor( colors.cyan )
  ComponentBase.draw( self )
  term.setTextColor( colors.cyan )
  -- Side bars.
  for i = 0, self.h - 1 do
    term.setCursorPos( self:get_x() - 1, self:get_y() + i )
    term.blit( VERTICAL_BAR, colors.toBlit( self.border_color ), colors.toBlit( self.bg_color ) )
  end
  -- If border are active.
  if self.has_border then
    term.setBackgroundColor( self.border_color )
    term.setTextColor( self.bg_color )
    paintutils.drawFilledBox( self:get_x(), self:get_y(), self.w + self:get_x() - 1, self:get_y(), self.border_color )
    local start_pos_x = self:get_x() + ( ( self.w - #self.title ) / 2 )
    term.setCursorPos( start_pos_x, self:get_y() )
    term.write( self.title )
    -- Side bars.
    for i = 0, self.h - 1 do
      term.setBackgroundColor( self.border_color )
      term.setTextColor( self.bg_color )
      term.setCursorPos( self:get_x() - 1, self:get_y() + i )
      term.write( LEFT_BAR )
      term.setBackgroundColor( self.bg_color )
      term.setTextColor( self.border_color )
      term.setCursorPos( self:get_x() + self.w, self:get_y() + i )
      term.write( RIGHT_BAR )
    end
    term.setCursorPos( self:get_x() - 1, self:get_y() + self.h )
    term.write( LEFT_CORNER )
    for i = 1, self.w do
      term.write( BOTTOM_BAR )
    end
    term.write( RIGHT_CORNER )
  end
end

return Panel