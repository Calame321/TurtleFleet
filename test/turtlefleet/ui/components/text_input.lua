local Input = require( "turtlefleet.ui.components.input" )

---@class TextInput
---@field text string
---@filed 
local TextInput = Input:inherit()
TextInput.__index = TextInput

local TEXT_CURSOR = string.char( 95 )

function TextInput:initialize( x, y, w )
  Input.initialize( self, x, y )
  self.text = ""
  self.selected_index = 1
  self.bg_color = colors.gray
  self.fg_color = colors.lightBlue
  self.confirmed = function() end
  self.w = w or 15
  self.h = 1
end

function TextInput.apply_focus( self, value )
  Input.apply_focus( self, value )
  self:draw()
  if value then self:blink( value ) end
end

function TextInput:clear()
  self.text = ""
  self:draw()
end

--- Controls for the text.
---@param key integer
function TextInput:on_key( key )
  if self.has_focus then
    self:blink( false )
    if key == keys.backspace then
      self.text = self.text:sub( 1, #self.text - 1 )
    elseif key == keys.enter then
      self.confirmed()
    end
    self:blink( true )
  end
end

function TextInput:set_confirmed( func )
  self.confirmed = func
  return self
end

function TextInput:on_char( char )
  if self.has_focus then
    self.text = self.text .. char
    self:draw()
  end
end

function TextInput:on_click( button, x, y )
  if button == 1 and not self:has_point( x, y ) then return end
  self.has_focus = true
  self:draw()
end

--- Draw the grid on screen.
function TextInput:draw()
  term.setCursorPos( self:get_x(), self:get_y() )
  term.setTextColor( self.fg_color )
  term.setBackgroundColor( self.bg_color )
  term.write( string.rep( " ", self.w ) )
  term.setCursorPos( self:get_x(), self:get_y() )
  term.write( self.text )
end

--- Blink the cursor in the grid to know where we are.
---@param state boolean If the cursor is visible.
function TextInput:blink( state )
  if self.has_focus then
    term.setBackgroundColor( self.bg_color )
    term.setCursorPos( self:get_x() + #self.text, self:get_y() )
    if state then
      term.write( TEXT_CURSOR )
    else
      term.write( " " )
    end
  end
end

return TextInput