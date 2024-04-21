local Page = require( "turtlefleet.ui.components.page" )
local Label = require( "turtlefleet.ui.components.label" )

---@class BackButton
local BackButton = Label:inherit()
BackButton.__index = BackButton

function BackButton:initialize( path )
  Label.initialize( self, string.char( 27 ) .. "Back", 1, 1 )
  self:set_bg( colors.blue ):set_fg( colors.white ):set_func( Page:change_to( path ), { keys.b } )
end

return BackButton