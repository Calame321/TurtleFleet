----------------------
-- TurtleFleet Main --
----------------------
if utils == nil then os.loadAPI( "turtlefleet/utils/utils.lua" ) end

if turtle == nil then
	os.loadAPI( "turtlefleet/computer/computer_startup" )
	computer_startup.run()
else
	-- Start the turtle code
	shell.run( "turtlefleet/turtle/turtle_startup.lua" )
end