----------------
-- Status Bar --
----------------
local status_bar = {}

-- Main variable
local status_bar.last_log = "---"
local status_bar.logs = {}
local status_bar.txt_color = colors.white
local status_bar.background_color = colors.lightGray
local status_bar.height = 1

function status_bar.set_log( log )
	if log == nil or log[ 1 ] == "timer" then
		return
	elseif log[ 1 ] == "mouse_click" then
		status_bar.last_log = "Click| btn: " .. log[ 2 ] .. " x: " .. log[ 3 ] .. " y:" .. log[ 4 ]
	else
		status_bar.last_log = log[ 1 ]
	end
end

function status_bar.set_color()
	term.setBackgroundColor( status_bar.background_color )
	term.setTextColor( status_bar.txt_color )
end

function status_bar.draw()
	local lastBgColor = term.getBackgroundColor()

	local sizeX, sizeY = term.getSize()
	
	paintutils.drawFilledBox( 1, sizeY - ( status_bar.height - 1 ), sizeX, sizeY, status_bar.background_color )
	
	-- Log
	term.setCursorPos( 1,  sizeY )
	write( " " .. status_bar.last_log .. " " )

	-- Time
	term.setCursorPos( sizeX - 9,  sizeY )
	write( textutils.formatTime( os.time(), true ) )

	term.setBackgroundColor( lastBgColor )
end

return status_bar