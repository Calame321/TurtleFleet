local Class = require( "turtlefleet.ui.components.class" )

---@class ComponentBase
---@field parent any The parent that contains this component.
---@field x integer The X position.
---@field y integer The Y position.
---@field w integer The width.
---@field h integer The height.
---@field bg_color integer The background color.
---@field fg_color integer The text color.
---@field components ComponentBase[] The list of components in the page.
---@field enabled boolean If the component is grayed out and taking input.
---@field monitor any The monitor or terminal to draw to.
local ComponentBase = Class:inherit()
ComponentBase.__index = ComponentBase
ComponentBase.coroutines = {}

--- Set the position and colors of the component.
---@param self any
---@param x integer
---@param y integer
function ComponentBase.initialize( self, x, y )
  self.x = x or 1
  self.y = y or 1
  self.w = 1
  self.h = 1
  self.bg_color = colors.white
  self.fg_color = colors.cyan
  self.components = {}
  self.enabled = true
end

--- Disable the component and it's children.
---@param self any
---@return any
function ComponentBase.disable( self )
  self.enabled = false
  for _, c in ipairs( self.components ) do c:disable() end
  return self
end

--- Enable the component and it's children.
---@param self any
---@return any
function ComponentBase.enable( self )
  self.enabled = true
  for _, c in ipairs( self.components ) do c:enable() end
  return self
end

--- Used to execute functions later.
--- Ex: Set the focus of a component a frame later to avoid input leaking.
function ComponentBase:resume_coroutines()
  for _, co in ipairs( self.coroutines ) do
    coroutine.resume( co )
  end
  for k, co in ipairs( self.coroutines ) do
    if coroutine.status( co ) == "dead" then
      table.remove( self.coroutines, k )
    end
  end
end

function ComponentBase:set_size( w, h )
  self.w = w
  self.h = h
  return self
end

function ComponentBase:get_x()
  if self.parent == nil then return self.x end
  return self.parent:get_x() + self.x - 1
end

--- Set the y position.
---@param y integer
---@return ComponentBase
function ComponentBase:set_y( y )
  self.y = y
  return self
end

function ComponentBase:get_y()
  if self.parent == nil then return self.y end
  return self.parent:get_y() + self.y - 1
end

function ComponentBase:set_bg( color )
  self.bg_color = color
  return self
end

function ComponentBase:set_fg( color )
  self.fg_color = color
  return self
end

--- Add a component to the page.
---@param component ComponentBase
function ComponentBase:add_component( component )
  component.parent = self
  table.insert( self.components, component )
  return self
end

function ComponentBase:remove_component( component )
  for k, c in ipairs( self.components ) do
    if c == component then
      self.components[ k ] = nil
      component = nil
      return
    end
  end
  self:draw()
end

function ComponentBase:on_key( key )
  if not self.enabled then return end
  for _, c in ipairs( self.components ) do
    if c.on_key then
      c:on_key( key )
    end
  end
end

function ComponentBase:on_char( char )
  if not self.enabled then return end
  for _, c in ipairs( self.components ) do
    if c.on_char then
      c:on_char( char )
    end
  end
end

function ComponentBase:on_click( button, x, y )
  if not self.enabled then return end
  for _, c in ipairs( self.components ) do
    if c.apply_focus then c.apply_focus( self, false ) end
  end
  for _, c in ipairs( self.components ) do
    if c.on_click then
      c:on_click( button, x, y )
    end
  end
end

--- Draw the child components.
---@param self any Any component that extends ComponentBase.
function ComponentBase.draw( self )
  if self.components == nil then return end
  for _, c in ipairs( self.components ) do c:draw() end
end

function ComponentBase:blink( state )
  for _, c in ipairs( self.components ) do c:blink( state ) end
end

--- Check if a position is on the component.
---@param x integer
---@param y integer
---@return boolean
function ComponentBase:has_point( x, y )
  local sx = self:get_x()
  local sy = self:get_y()
  return sx <= x and sx + self.w - 1 >= x and sy <= y and sy + self.h - 1 >= y
end

return ComponentBase