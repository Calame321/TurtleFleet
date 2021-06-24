-----------
-- Popup --
-----------
local popup = {}

-- Main variable
popup.text = ""
popup.visible = false
popup.utils = require( "turtlefleet.utils.utils" )

function popup.draw()
    if not popup.visible then return end

	local lastBgColor = term.getBackgroundColor()
    local x, y = term.getSize()
    
    paintutils.drawFilledBox( 4, 4, x - 3, y - 3, colors.white )
    paintutils.drawBox( 3, 3, x - 2, y - 2, colors.gray )
    paintutils.drawLine( 4, 7, x - 3, 7, colors.gray )
    
    local title = "Information"
    local startX = popup.utils.get_center_x( string.len( title ), x )

    term.setBackgroundColor( colors.white )
    term.setTextColor( colors.black )
    term.setCursorPos( startX, 5 )

    write( title )

    startX = popup.utils.get_center_x( string.len( popup.text ), x )
    term.setCursorPos( startX, 9 )

    write( popup.text )
	term.setBackgroundColor( lastBgColor )
end

function popup.show( txt )
    popup.text = txt
    popup.visible = true
end

function popup.hide()
    popup.visible = false
end

return popup