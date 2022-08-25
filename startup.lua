----------------------
-- TurtleFleet Main --
----------------------
if turtle == nil then
	os.loadAPI( "turtlefleet/computer/computer_startup.lua" )
	--computer_startup.run()
else
	-- Start the turtle code
	shell.run( "turtlefleet/turtle/turtle_startup.lua" )
end