------------
-- Update --
------------
local update = {}

update.git_path = "https://raw.githubusercontent.com/Calame321/TurtleFleet/main/"
update.fleet_folder = "turtlefleet/"
update.all_files = {
  "computer/computer_startup.lua",
  "turtle/jobs/builder.lua",
  "turtle/jobs/harvester.lua",
  "turtle/jobs/lumberjack.lua",
  "turtle/jobs/miner.lua",
  "turtle/jobs/smelter.lua",
  "turtle/advanced_turtle.lua",
  "turtle/fleet_mode.lua",
  "turtle/pathfind.lua",
  "turtle/turtle_menu.lua",
  "turtle/turtle_startup.lua",
  "utils/update.lua",
}

function update.master()
  local is_master = false

  while turtle.suckDown( 1 ) do
    is_master = true
    turtle.place()
    peripheral.call( "front", "turnOn" )

    local valid_signal = false

    while not valid_signal do
      os.pullEvent( "redstone" )

      if rs.getAnalogueInput( "front", 1 ) then
        valid_signal = true
      end
    end

    turtle.dig()
    turtle.dropUp()
  end

  if is_master then turtle.forward() end
  update.update()
end

function update.update()
  fs.delete( "startup" )
  fs.delete( "turtlefleet" )

  for i = 1, #update.all_files do
    update.get_file_from_github( update.all_files[ i ] )
  end

  update.get_startup_from_github()
  rs.setAnalogueOutput( "back", 1 )
  os.sleep( 0.05 )
  rs.setAnalogueOutput( "back", 0 )
end

function update.get_file_from_github( file_path, in_folder )
  local f = fs.open( update.fleet_folder .. file_path, "w" )
  local w, m = http.get( update.git_path .. file_path )
  if w then
    f.write( w.readAll() )
    f.flush()
    f.close()
  else
    print( "Cant load '", file_path, "' : ", m )
  end
end

function update.get_startup_from_github()
  local f = fs.open( "startup", "w" )
  local w, m = http.get( update.git_path .. "startup.lua" )
  if w then
    f.write( w.readAll() )
    f.flush()
    f.close()
  else
    print( "Cant load 'startup':", m )
  end
end

--for i = 1, #update.all_files do
--  if not fs.exists( update.fleet_folder .. update.all_files[ i ] ) then
--    print( "Updating..." )
--    update.update()
--    print( "Updated! press a key to reboot" )
--    read()
--    os.reboot()
--  end
--end

return update