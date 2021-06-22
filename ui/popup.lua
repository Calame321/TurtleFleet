-----------
-- Popup --
-----------

-- Main variable
local text = ""
local visible = false
local btnOk = false

function draw()
    if not visible then
        return
    end

	local lastBgColor = term.getBackgroundColor()

    local x, y = term.getSize()
    
    paintutils.drawFilledBox( 4, 4, x - 3, y - 3, colors.white )
    paintutils.drawBox( 3, 3, x - 2, y - 2, colors.gray )
    paintutils.drawLine( 4, 7, x - 3, 7, colors.gray )
    
    local title = "Information"
    local startX = utils.getCenterX( string.len( title ), x )

    term.setBackgroundColor( colors.white )
    term.setTextColor( colors.black )
    term.setCursorPos( startX, 5 )

    write( title )

    startX = utils.getCenterX( string.len( text ), x )
    term.setCursorPos( startX, 9 )

    write( text )

	term.setBackgroundColor( lastBgColor )
end

function isVisible()
    return visible
end

function show( txt )
    text = txt
    visible = true
end

function hide()
    visible = false
end