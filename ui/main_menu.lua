---------------
-- Main Menu --
---------------
local main_menu = {}

main_menu.popup = require( "popup" )
main_menu.icon_grid = require( "icon_grid" )
main_menu.status_bar = require( "status_bar" )
main_menu.top_menu_bar = require( "top_menu_bar" )

function main_menu.on_click( x, y )
	main_menu.top_menu_bar.on_click( x, y )
end

function main_menu.on_char( char )
	main_menu.top_menu_bar.on_char( char )
end

function main_menu.on_peripheral( side )
	local type = peripheral.getType( side )

	if type == "modem" and side == "top" then
		main_menu.popup.hide()
		os.queueEvent( "modem_connected" )
	end
end

function main_menu.on_peripheral_detach( side )
	if side == "top" then
		main_menu.popup.show( "Please, place a modem on top." )
	end
end

function main_menu.draw( event )
	term.clear()
	if event then
		if event[ 1 ] == "mouse_click" then
			main_menu.on_click( event[ 3 ], event[ 4 ] )
		elseif event[ 1 ] == "char" then
			main_menu.on_char( event[ 2 ] )
		elseif event[ 1 ] == "peripheral" then
			main_menu.on_peripheral( event[ 2 ] )
		elseif event[ 1 ] == "peripheral_detach" then
			main_menu.on_peripheral_detach( event[ 2 ] )
		end
	end

	main_menu.icon_grid.set_start_y( main_menu.top_menu_bar.height )
	main_menu.icon_grid.draw()

	main_menu.top_menu_bar.draw()
	main_menu.popup.draw()

	main_menu.status_bar.set_log( event )
	main_menu.status_bar.draw()
	term.setBackgroundColor( colors.black )
end

--Execute on load
function main_menu.on_load()
	if ( peripheral.getType( "top" ) == nil ) then
		main_menu.on_peripheral_detach( "top" )
	else
		os.queueEvent( "peripheral", "modem", "top" )
	end
end

return main_menu