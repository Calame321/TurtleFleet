local Input = require( "turtlefleet.ui.components.input" )

---@class ListInput
---@field data string[]
local ListInput = Input:inherit()
ListInput.__index = ListInput

local up_arrow = string.char( 30 )
local down_arrow = string.char( 31 )
local bar = string.char( 127 )

function ListInput:initialize( x, y, w, h )
  Input.initialize( self, x, y )
  self.selected_index = 1
  self.bg_color = colors.lightGray
  self.bg2_color = colors.lightBlue
  self.fg_color = colors.white
  self.w = w or 15
  self.h = h or 4
  self.data = {}
  self.data_added = function() end
end

function ListInput:on_data_added( func )
  self.data_added = func
  return self
end

function ListInput.apply_focus( self, value )
  Input.apply_focus( self, value )
  self:draw()
  if value then self:blink( value ) end
end

--- Set data from existing source.
---@param data string[]
function ListInput:set_data( data )
  for _, v in ipairs( data ) do
    table.insert( self.data, v )
  end
  self:draw()
end

--- Add a new data.
--- If it already exists, it is removed instead.
---@param value string
function ListInput:add_data( value )
  local value_index = table.contains( self.data, value )
  if value_index then
    table.remove( self.data, value_index )
  else
    table.insert( self.data, value )
  end
  self.data_added()
  self:draw()
end

function ListInput:clear()
  self.data = {}
  self:draw()
end

--- Controls for the text.
---@param key integer
function ListInput:on_key( key )
  if self.has_focus then
    self:blink( false )
    if key == keys.backspace then
      self.text = self.text:sub( 1, #self.text - 1 )
    end
    self:blink( true )
  end
end

function ListInput:on_click( button, x, y )
  if button == 1 and not self:has_point( x, y ) then return end
  self.has_focus = true
  self:draw()
end

--- Draw the grid on screen.
function ListInput:draw()
  -- If disabled.
  local bg2 = self.bg2_color
  if not self.enabled then bg2 = colors.gray end
  -- Offset if a scroll bar is needed.
  local bar_offset = 0
  if self.h < #self.data then bar_offset = 1 end
  -- Draw the lines.
  for i = 1, self.h do
    term.setCursorPos( self:get_x(), self:get_y() + i - 1 )
    term.setTextColor( self.fg_color )
    if i % 2 == 1 then
      term.setBackgroundColor( self.bg_color )
    else
      term.setBackgroundColor( bg2 )
    end
    term.write( string.rep( " ", self.w - bar_offset ) )
    term.setCursorPos( self:get_x(), self:get_y() + i - 1 )
    if self.data[ i ] then
      term.write( self.data[ i ]:sub( 1, self.w - bar_offset ) )
    end
  end
  -- Draw the scroll bar.
  if bar_offset == 1 then
    term.setCursorPos( self:get_x() + self.w - 1, self:get_y() )
    term.write( up_arrow )
    for i = 1, self.h - 2 do
      term.setCursorPos( self:get_x() + self.w - 1, self:get_y() + i )
      term.write( bar )
    end
    term.setCursorPos( self:get_x() + self.w - 1, self:get_y() + self.h - 1 )
    term.write( down_arrow )
  end
end

--- Blink the cursor in the grid to know where we are.
---@param state boolean If the cursor is visible.
function ListInput:blink( state )
  if self.has_focus then
    
  end
end

return ListInput