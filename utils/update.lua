------------
-- Update --
------------
local update = {}

update.git_path = "https://raw.githubusercontent.com/Calame321/TurtleFleet/main/"
update.fleet_folder = "turtlefleet/"
update.all_files = {
    "computer/computer_startup.lua",
    "control/disk_install.lua",
    "control/manual_command.lua",
    "control/network.lua",
    "jobs/builder.lua",
    "jobs/cooker.lua",
    "jobs/job.lua",
    "jobs/miner.lua",
    "stations/mine.lua",
    "stations/station.lua",
    "stations/treefarm.lua",
    "turtle/advanced_turtle.lua",
    "turtle/pathfind.lua",
    "turtle/turtle_startup.lua",
    "ui/icon_grid.lua",
    "ui/main_menu.lua",
    "ui/popup.lua",
    "ui/status_bar.lua",
    "ui/top_menu_bar.lua",
    "utils/position.lua",
    "utils/update.lua",
    "utils/utils.lua",
    "img/mine",
    "img/tree",
    "img/inventory",
    "img/icon_missing",
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

    for i = 1, #update.all_files do update.get_file_from_github( update.all_files[ i ] ) end
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
        print( "Cant load '" .. file_path .. "' : " .. m )
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
        print( "Cant load 'startup' : " .. m )
    end
end

for i = 1, #update.all_files do
    if not fs.exists( update.fleet_folder .. update.all_files[ i ] ) then
        print( "Updating..." )
        update.update()
        print( "Updated! press a key to reboot" )
        read()
        os.reboot()
    end
end

return update