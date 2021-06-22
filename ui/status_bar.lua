----------------
-- Status Bar --
----------------

-- Main variable
local lastLog = "---"
local logs = {}
local txtColor = colors.white
local backgroundColor = colors.lightGray
local height = 1
local isOpen = false

function setLog( log )
	if log == nil or log[ 1 ] == "timer" then
		return
	elseif log[ 1 ] == "mouse_click" then
		lastLog = "Click| btn: " .. log[ 2 ] .. " x: " .. log[ 3 ] .. " y:" .. log[ 4 ]
	else
		lastLog = log[ 1 ]
	end
end

function setColor()
	term.setBackgroundColor( backgroundColor )
	term.setTextColor( txtColor )
end

function draw()
	local lastBgColor = term.getBackgroundColor()

	local sizeX, sizeY = term.getSize()
	
	paintutils.drawFilledBox( 1, sizeY - ( height - 1 ), sizeX, sizeY, backgroundColor )
	
	-- Log
	term.setCursorPos( 1,  sizeY )
	write( " " .. lastLog .. " " )

	-- Time
	term.setCursorPos( sizeX - 9,  sizeY )
	write( textutils.formatTime( os.time(), true ) )

	term.setBackgroundColor( lastBgColor )
end