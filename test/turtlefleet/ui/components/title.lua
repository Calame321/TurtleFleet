local ComponentBase = require( "turtlefleet.ui.components.component_base" )

---@class Title
---@field title string The title.
---@field symbol string A simbol to decorate the tile.
---@field symbol_color integer The color of the symbol.
local Title = ComponentBase:inherit()
Title.__index = Title

function Title:initialize( title, symbol, symbol_color )
  ComponentBase.initialize( self, 1, 1 )
  self.title = title
  self.bg_color = colors.blue
  self.fg_color = colors.white
  self.symbol = symbol
  self.symbol_color = symbol_color
end

function Title:draw()
  term.setBackgroundColor( self.bg_color )
  term.setCursorPos( 1, 1 )
  paintutils.drawFilledBox( 1, 1, term.width, 1, self.bg_color )
  local start_pos_x = 1 + ( ( term.width - #self.title ) / 2 )
  term.setCursorPos( start_pos_x, 1 )
  term.setTextColor( self.fg_color )
  term.write( self.title )
  term.setCursorPos( start_pos_x - 4, 1 )
  term.setTextColor( self.symbol_color )
  term.write( self.symbol .. " -" )
  term.setCursorPos( start_pos_x + #self.title, 1 )
  term.write( " - " .. self.symbol )
end

return Title