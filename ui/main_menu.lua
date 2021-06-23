---------------
-- Main Menu --
---------------
local main_menu = {}

main_menu.icon_grid = require( "turtlefleet.ui.icon_grid" )
main_menu.popup = require( "turtlefleet.ui.popup" )
main_menu.status_bar = require( "turtlefleet.ui.status_bar" )
main_menu.top_menu_bar = require( "turtlefleet.ui.main_menu.top_menu_bar" )

main_menu.top_menu_bar.addMenuItem( "file", "File" )
main_menu.top_menu_bar.addSubItem( "file", "reboot"	 , "Reboot"		 , function() os.reboot() 	end )
main_menu.top_menu_bar.addSubItem( "file", "shutdown", "Shutdown"	 , function() os.shutdown() end )
main_menu.top_menu_bar.addSubItem( "file", "returnOs", "Return to OS", function() os.exit() 	end )

main_menu.top_menu_bar.addMenuItem( "option", "Option" )
main_menu.top_menu_bar.addSubItem( "option", "settings", "Settings", function() print( "Setting" ) end )
main_menu.top_menu_bar.addSubItem( "option", "about"   , "About"   , function() print( "About"   ) end )

main_menu.top_menu_bar.addMenuItem( "help", "Help" )
main_menu.top_menu_bar.addSubItem( "help", "status"		, "Status"	 , function() os.queueEvent( "Status", 1, "1") end )
main_menu.top_menu_bar.addSubItem( "help", "inventory"	, "Inventory", function() print( "Inventory") end )
main_menu.top_menu_bar.addSubItem( "help", "crafting"	, "Crafting" , function() print( "Crafting"	) end )
main_menu.top_menu_bar.addSubItem( "help", "mining"		, "Mining"	 , function() print( "Mining"	) end )
main_menu.top_menu_bar.addSubItem( "help", "building"	, "Building" , function() print( "Building"	) end )
main_menu.top_menu_bar.addSubItem( "help", "highway"	, "Highway"	 , function() print( "Highway"	) end )
main_menu.top_menu_bar.addSubItem( "help", "station"	, "Station"	 , function() print( "Station"	) end )
main_menu.top_menu_bar.addSubItem( "help", "log"		, "Log"		 , function() print( "Log"		) end )

main_menu.icon_grid.addIcon( "status"	 , "Status"   , function() end )
main_menu.icon_grid.addIcon( "inventory", "Inventory", function() end, "inventory" )
main_menu.icon_grid.addIcon( "crafting" , "Crafting" , function() end )
main_menu.icon_grid.addIcon( "mining"	 , "Mining"   , function() end, "mine" 		)
main_menu.icon_grid.addIcon( "building" , "Building" , function() end, "tree" 		)
main_menu.icon_grid.addIcon( "highway"	 , "Highway"  , function() end )
main_menu.icon_grid.addIcon( "station"	 , "Station"  , function() end )
main_menu.icon_grid.addIcon( "log"		 , "Log" 	  , function() end )

function main_menu.on_click( x, y )
	main_menu.top_menu_bar.on_click( x, y )
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
		elseif event[ 1 ] == "peripheral" then
			main_menu.on_peripheral( event[ 2 ] )
		elseif event[ 1 ] == "peripheral_detach" then
			main_menu.on_peripheral_detach( event[ 2 ] )
		end
	end

	main_menu.icon_grid.set_start_y( main_menu.top_menu_bar.get_height() )
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