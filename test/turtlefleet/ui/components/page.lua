local ComponentBase = require( "turtlefleet.ui.components.component_base" )

---@class Page
---@field x integer The width of the page.
---@field y integer The height of the page.
---@field debug Label The debug label of the page (could be moved to the main ui?).
local Page = ComponentBase:inherit()
Page.__index = Page

--- Set the position and size of the component.
---@param self any A class that inherits ComponentBase.
---@param monitor any The monitor to redirect to, else we use term.
function Page.initialize( self, monitor )
  ComponentBase.initialize( self, 1, 1 )
  self.term = monitor or term
  local width, height = self.term.getSize()
  self.x = 1
  self.y = 1
  self.w = width
  self.h = height
  self.monitor = monitor
end

--- Set a monitor to draw.
---@param monitor any
---@return Page
function Page:set_term( monitor )
  self.monitor = monitor
  self.term = monitor
  return self
end

--- Draw the background of the page.
---@param self any A class that inherits ComponentBase.
function Page.draw( self )
  -- Redirect to a monitor id available.
  local old_term
  if self.monitor then old_term = term.redirect( self.monitor ) end
  -- Draw stuff.
  paintutils.drawFilledBox( self:get_x(), self:get_y(), self.w, self.h, colors.white )
  self.term.setTextColor( colors.cyan )
  ComponentBase.draw( self )
  -- Undo the redirect.
  if self.monitor then term.redirect( old_term ) end
end

--- Return a function that change the page.
---@param page string
---@return function
function Page:change_to( page )
  return function()
    os.queueEvent( "page_selected", page )
  end
end

return Page