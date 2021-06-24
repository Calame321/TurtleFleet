----------------------
-- Computer Startup --
----------------------
main_menu = require( "main_menu" )

main_menu.top_menu_bar.add_menu_item( "file", "File" )
main_menu.top_menu_bar.add_sub_item( "file", "reboot"  , "Reboot"	   , function() os.reboot()   end )
main_menu.top_menu_bar.add_sub_item( "file", "shutdown", "Shutdown"	   , function() os.shutdown() end )
main_menu.top_menu_bar.add_sub_item( "file", "returnOs", "Return to OS", function() os.exit() 	  end )

main_menu.top_menu_bar.add_menu_item( "option", "Option" )
main_menu.top_menu_bar.add_sub_item( "option", "settings", "Settings", function() print( "Setting" ) end )
main_menu.top_menu_bar.add_sub_item( "option", "about"   , "About"   , function() print( "About"   ) end )

main_menu.top_menu_bar.add_menu_item( "help", "Help" )
main_menu.top_menu_bar.add_sub_item( "help", "status"	, "Status"	 , function() os.queueEvent( "Status", 1, "1") end )
main_menu.top_menu_bar.add_sub_item( "help", "inventory", "Inventory", function() print( "Inventory") end )
main_menu.top_menu_bar.add_sub_item( "help", "crafting"	, "Crafting" , function() print( "Crafting"	) end )
main_menu.top_menu_bar.add_sub_item( "help", "mining"	, "Mining"	 , function() print( "Mining"	) end )
main_menu.top_menu_bar.add_sub_item( "help", "building"	, "Building" , function() print( "Building"	) end )
main_menu.top_menu_bar.add_sub_item( "help", "highway"	, "Highway"	 , function() print( "Highway"	) end )
main_menu.top_menu_bar.add_sub_item( "help", "station"	, "Station"	 , function() print( "Station"	) end )
main_menu.top_menu_bar.add_sub_item( "help", "log"		, "Log"		 , function() print( "Log"		) end )

main_menu.icon_grid.add_icon( "status"	 , "Status"   , function() end )
main_menu.icon_grid.add_icon( "inventory", "Inventory", function() end, "inventory" )
main_menu.icon_grid.add_icon( "crafting" , "Crafting" , function() end )
main_menu.icon_grid.add_icon( "mining"	 , "Mining"   , function() end, "mine" 		)
main_menu.icon_grid.add_icon( "building" , "Building" , function() end, "tree" 		)
main_menu.icon_grid.add_icon( "highway"	 , "Highway"  , function() end )
main_menu.icon_grid.add_icon( "station"	 , "Station"  , function() end )
main_menu.icon_grid.add_icon( "log"		 , "Log" 	  , function() end )


function savePos( pos )
    settings.set( "pos", { face = pos.face, coords = pos.coords } )
    setting.save( ".settings" )
end

function onModemConnected()
    rednet.open( "top" )
    rednet.host( "tf", "main" )
end

function onNetMessage( event )
    if event[ 3 ] == "getJob" then
        rednet.send( event[ 2 ], "Scout" )
    end
end

function run()
    local posSetting = settings.get( "pos" )
    --local pos = Position:new()

    if posSetting ~= nil then
        pos:init( posSetting )
    end

    -- Timer to display time
    local clockTimer = os.startTimer( 1 )
    
    while true do
        event = { os.pullEvent() }
        if event[ 1 ] == "timer" and event[ 2 ] == clockTimer then
            clockTimer = os.startTimer( 1 )
        elseif event[ 1 ] == "modem_connected" then
            onModemConnected()
        elseif event[ 1 ] == "rednet_message" then
			onNetMessage( event )
        end

        term.clear()
        main_menu.draw( event )
        term.setBackgroundColor( colors.black )
    end
end