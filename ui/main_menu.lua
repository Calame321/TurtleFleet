---------------
-- Main Menu --
---------------
os.loadAPI( "turtlefleet/ui/top_menu_bar.lua" )
os.loadAPI( "turtlefleet/ui/icon_grid.lua"    )
os.loadAPI( "turtlefleet/ui/status_bar.lua"   )
os.loadAPI( "turtlefleet/ui/popup.lua"  	  )

top_menu_bar.addMenuItem( "file", "File" )
top_menu_bar.addSubItem( "file", "reboot"	 , "Reboot"		 , function() os.reboot() 	end )
top_menu_bar.addSubItem( "file", "shutdown", "Shutdown"	 , function() os.shutdown() end )
top_menu_bar.addSubItem( "file", "returnOs", "Return to OS", function() os.exit() 	end )

top_menu_bar.addMenuItem( "option", "Option" )
top_menu_bar.addSubItem( "option", "settings", "Settings", function() print( "Setting" ) end )
top_menu_bar.addSubItem( "option", "about"   , "About"   , function() print( "About"   ) end )

top_menu_bar.addMenuItem( "help", "Help" )
top_menu_bar.addSubItem( "help", "status"		, "Status"	 , function() os.queueEvent( "Status", 1, "1") end )
top_menu_bar.addSubItem( "help", "inventory"	, "Inventory", function() print( "Inventory") end )
top_menu_bar.addSubItem( "help", "crafting"	, "Crafting" , function() print( "Crafting"	) end )
top_menu_bar.addSubItem( "help", "mining"		, "Mining"	 , function() print( "Mining"	) end )
top_menu_bar.addSubItem( "help", "building"	, "Building" , function() print( "Building"	) end )
top_menu_bar.addSubItem( "help", "highway"	, "Highway"	 , function() print( "Highway"	) end )
top_menu_bar.addSubItem( "help", "station"	, "Station"	 , function() print( "Station"	) end )
top_menu_bar.addSubItem( "help", "log"		, "Log"		 , function() print( "Log"		) end )

icon_grid.addIcon( "status"	 , "Status"   , function() end )
icon_grid.addIcon( "inventory", "Inventory", function() end, "inventory" )
icon_grid.addIcon( "crafting" , "Crafting" , function() end )
icon_grid.addIcon( "mining"	 , "Mining"   , function() end, "mine" 		)
icon_grid.addIcon( "building" , "Building" , function() end, "tree" 		)
icon_grid.addIcon( "highway"	 , "Highway"  , function() end )
icon_grid.addIcon( "station"	 , "Station"  , function() end )
icon_grid.addIcon( "log"		 , "Log" 	  , function() end )

function onClick( x, y )
	top_menu_bar.onClick( x, y )
end

function onPeripheral( side )
	local type = peripheral.getType( side )

	if type == "modem" and side == "top" then
		popup.hide()
		os.queueEvent( "modem_connected" )
	end
end

function onPeripheralDetach( side )
	if side == "top" then
		popup.show( "Please, place a modem on top." )
	end
end

function draw( event )
	term.clear()
	if event then
		if event[ 1 ] == "mouse_click" then
			onClick( event[ 3 ], event[ 4 ] )
		elseif event[ 1 ] == "peripheral" then
			onPeripheral( event[ 2 ] )
		elseif event[ 1 ] == "peripheral_detach" then
			onPeripheralDetach( event[ 2 ] )
		end
	end

	icon_grid.setStartY( top_menu_bar.getHeight() )
	icon_grid.draw()

	top_menu_bar.draw()
	popup.draw()

	status_bar.setLog( event )
	status_bar.draw()
	term.setBackgroundColor( colors.black )
end

--Execute on load
function on_load()
	if ( peripheral.getType( "top" ) == nil ) then
		onPeripheralDetach( "top" )
	else
		os.queueEvent( "peripheral", "modem", "top" )
	end
end

return {
	onClick = onClick,
	onPeripheral = onPeripheral,
	onPeripheralDetach = onPeripheralDetach,
	draw = draw,
	on_load = on_load
}