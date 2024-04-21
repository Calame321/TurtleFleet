local Input = require( "turtlefleet.ui.components.input" )

---@class InventoryGrid
---@field cells integer[] Colors.
---@field selected_color integer The color that will be applied to cells.
---@field selected_index integer Selected cell when focused.
---@field selected function Function to call when a cell is selected.
local InventoryGrid = Input:inherit()
InventoryGrid.__index = InventoryGrid

local C129 = string.char( 129 )
local C131 = string.char( 131 )
local C148 = string.char( 148 )
local C149 = string.char( 149 )
local C151 = string.char( 151 )

function InventoryGrid:initialize( x, y )
  Input.initialize( self, x, y )
  self.cells = {}
  self.selected_index = 1
  self.selected_color = colors.gray
  self.selected = function() end
  self.index_changed = function() end
  self.w = 7
  self.h = 5
  for _ = 1, 16 do
    table.insert( self.cells, self.bg_color )
  end
end

function InventoryGrid.apply_focus( self, value )
  Input.apply_focus( self, value )
  self:draw()
  if value then self:blink( value ) end
end

--- The function to call when the selection is confirmed by a click or enter.
---@param func function
---@return InventoryGrid
function InventoryGrid:on_selected( func )
  self.selected = func
  return self
end

--- The function to call when the selection is changed by the arrow keys.
---@param func function
---@return InventoryGrid
function InventoryGrid:on_index_changed( func )
  self.index_changed = func
  return self
end

--- Set the color to apply to a cell.
---@param color integer
---@return InventoryGrid
function InventoryGrid:set_color( color )
  self.selected_color = color
  return self
end

--- When the selected index is changed with arrow keys.
---@param index integer
function InventoryGrid:change_selected_index( index )
  self.selected_index = index
---@diagnostic disable-next-line: redundant-parameter
  self.index_changed( index )
end

--- Move the cursor in the grid.
---@param key integer
function InventoryGrid:on_key( key )
  if self.has_focus then
    self:blink( false )
    local x = ( self.selected_index - 1 ) % 4
    local y = math.floor( ( self.selected_index - 1 ) / 4 )
    if key == keys.up then
      self:change_selected_index( math.max( x + 1, self.selected_index - 4 ) )
    elseif key == keys.down then
      self:change_selected_index( math.min( 13 + x, self.selected_index + 4 ) )
    elseif key == keys.left then
      self:change_selected_index( math.max( ( y * 4 ) + 1, self.selected_index - 1 ) )
    elseif key == keys.right then
      self:change_selected_index( math.min( ( y + 1 ) * 4, self.selected_index + 1 ) )
    elseif key == keys.enter then
      self:set_cell_color( self.selected_index )
      self:selected()
    end
    self:blink( true )
  end
end

function InventoryGrid:on_click( button, x, y )
  if button == 1 and not self:has_point( x, y ) then return end
  for k, v in ipairs( self.cells ) do
    local row_index = math.floor( ( k - 1 ) / 4 )
    local group_index = math.floor( k / 2 )

    if k % 2 == 0 then
      local even_x = ( ( ( group_index + 1 ) % 2 ) + 1 ) * 3
      if self:get_x() + even_x - 1 == x and self:get_y() + row_index == y then
        self:set_cell_color( k )
        self.selected_index = k
        self:selected()
      end
    else
      local odd_x = ( ( group_index % 2 ) * 3 )
      if ( self:get_x() + odd_x == x or self:get_x() + odd_x + 1 == x ) and self:get_y() + row_index == y then
        self:set_cell_color( k )
        self.selected_index = k
        self:selected()
      end
    end
  end
  self.has_focus = false
  self:draw()
end

--- Set the color of a cell.
---@param cell_index integer Colors.
function InventoryGrid:set_cell_color( cell_index )
  if turtle then turtle.select( cell_index ) end
  if self.cells[ cell_index ] == self.selected_color then
    self.cells[ cell_index ] = self.bg_color
  else
    self.cells[ cell_index ] = self.selected_color
  end
end

function InventoryGrid:is_cell_empty( index )
  return self.cells[ index ] == self.bg_color
end

--- Draw the grid on screen.
function InventoryGrid:draw()
  term.setTextColor( self.fg_color )
  term.setBackgroundColor( self.bg_color )
  local grid_fg = ""
  local grid_bg = ""
  for k, v in ipairs( self.cells ) do
    local cell_color = colors.toBlit( v )
    if k % 2 == 0 then
      grid_fg = grid_fg .. colors.toBlit( self.fg_color )
      grid_bg = grid_bg .. cell_color
    else
      grid_fg = grid_fg .. colors.toBlit( self.fg_color ) .. cell_color
      grid_bg = grid_bg .. cell_color .. colors.toBlit( self.fg_color )
    end
  end
  for i = 1, 4 do
    term.setCursorPos( self:get_x(), self:get_y() + i - 1 )
    local cell_text = C151 .. C148 .. C131 .. C151 .. C148 .. C131 .. C149
    local row_range = ( i - 1 ) * 6
    local cell_fg = string.sub( grid_fg, row_range + 1, row_range + 6 ) .. colors.toBlit( self.fg_color )
    local cell_bg = string.sub( grid_bg, row_range + 1, row_range + 6 ) .. colors.toBlit( self.bg_color )
    term.blit( cell_text, cell_fg, cell_bg )
  end
  term.setCursorPos( self:get_x(), self:get_y() + 4 )
  term.blit( string.rep( C131, 6 ) .. C129, string.rep( colors.toBlit( self.fg_color ), 7 ), string.rep( colors.toBlit( self.bg_color ), 7 ) )
end

--- Blink the cursor in the grid to know where we are.
---@param state boolean If the cursor is visible.
function InventoryGrid:blink( state )
  if self.has_focus then
    -- selected_index
    local x = ( self.selected_index - 1 ) % 4
    local grp_index = math.ceil( ( x + 1 ) / 2 )
    local fx = self:get_x() + x
    local fy = self:get_y() + math.floor( ( self.selected_index - 1 ) / 4 )
    local fg = colors.toBlit( self.fg_color )
    local bg = colors.toBlit( self.cells[ self.selected_index ] )
    local bl = colors.toBlit( colors.pink )
    local txt, fg_txt, bg_txt
    if self.selected_index % 2 == 1 then
      txt = C151 .. C148
      if state then
        fg_txt = fg .. bl
        bg_txt = bl .. fg
      else
        fg_txt = fg .. bg
        bg_txt = bg .. fg
      end
    else
      txt = C131
      if state then
        fg_txt = fg
        bg_txt = bl
      else
        fg_txt = fg
        bg_txt = bg
      end
    end
    term.setCursorPos( fx + ( grp_index - ( self.selected_index % 2 ) ), fy )
    term.blit( txt, fg_txt, bg_txt )
  end
end

return InventoryGrid