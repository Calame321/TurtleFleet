---------------
-- Main Menu --
---------------

os.loadAPI( "disk/turtleFleet/ui/topMenuBar" )
os.loadAPI( "disk/turtleFleet/ui/iconGrid"   )
os.loadAPI( "disk/turtleFleet/ui/statusBar"  )
os.loadAPI( "disk/turtleFleet/ui/popup"  	 )

topMenuBar.addMenuItem( "file", "File" )
topMenuBar.addSubItem( "file", "reboot"	 , "Reboot"		 , function() os.reboot() 	end )
topMenuBar.addSubItem( "file", "shutdown", "Shutdown"	 , function() os.shutdown() end )
topMenuBar.addSubItem( "file", "returnOs", "Return to OS", function() os.exit() 	end )

topMenuBar.addMenuItem( "option", "Option" )
topMenuBar.addSubItem( "option", "settings", "Settings", function() print( "Setting" ) end )
topMenuBar.addSubItem( "option", "about"   , "About"   , function() print( "About"   ) end )

topMenuBar.addMenuItem( "help", "Help" )
topMenuBar.addSubItem( "help", "status"		, "Status"	 , function() os.queueEvent( "Status", 1, "1") end )
topMenuBar.addSubItem( "help", "inventory"	, "Inventory", function() print( "Inventory") end )
topMenuBar.addSubItem( "help", "crafting"	, "Crafting" , function() print( "Crafting"	) end )
topMenuBar.addSubItem( "help", "mining"		, "Mining"	 , function() print( "Mining"	) end )
topMenuBar.addSubItem( "help", "building"	, "Building" , function() print( "Building"	) end )
topMenuBar.addSubItem( "help", "highway"	, "Highway"	 , function() print( "Highway"	) end )
topMenuBar.addSubItem( "help", "station"	, "Station"	 , function() print( "Station"	) end )
topMenuBar.addSubItem( "help", "log"		, "Log"		 , function() print( "Log"		) end )

iconGrid.addIcon( "status"	 , "Status"   , function() end )
iconGrid.addIcon( "inventory", "Inventory", function() end, "inventory" )
iconGrid.addIcon( "crafting" , "Crafting" , function() end )
iconGrid.addIcon( "mining"	 , "Mining"   , function() end, "mine" 		)
iconGrid.addIcon( "building" , "Building" , function() end, "tree" 		)
iconGrid.addIcon( "highway"	 , "Highway"  , function() end )
iconGrid.addIcon( "station"	 , "Station"  , function() end )
iconGrid.addIcon( "log"		 , "Log" 	  , function() end )

function onClick( x, y )
	topMenuBar.onClick( x, y )
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
	if event then
		if event[ 1 ] == "mouse_click" then
			onClick( event[ 3 ], event[ 4 ] )
		elseif event[ 1 ] == "peripheral" then
			onPeripheral( event[ 2 ] )
		elseif event[ 1 ] == "peripheral_detach" then
			onPeripheralDetach( event[ 2 ] )
		end
	end

	iconGrid.setStartY( topMenuBar.getHeight() )
	iconGrid.draw()

	topMenuBar.draw()
	popup.draw()

	statusBar.setLog( event )
	statusBar.draw()
end

--Execute on load
if ( peripheral.getType( "top" ) == nil ) then
	onPeripheralDetach( "top" )
else
	os.queueEvent( "peripheral", "modem", "top" )
end