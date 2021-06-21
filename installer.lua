local git_path = "https://raw.githubusercontent.com/Calame321/TurtleFleet/main/"

function update()
    fs.delete( "startup" )
    fs.delete( "TurtleFleet" )
    get_file_from_github( git_path .. "Turtle/advanced_turtle.lua"  ,"TurtleFleet/Turtle/advanced_turtle.lua" )
    get_file_from_github( git_path .. "Turtle/pathfind.lua"         ,"TurtleFleet/Turtle/pathfind.lua" )
    get_file_from_github( git_path .. "Stations/station.lua"        ,"TurtleFleet/Stations/station.lua" )
    get_file_from_github( git_path .. "Stations/treefarm.lua"       ,"TurtleFleet/Stations/treefarm.lua" )
    get_file_from_github( git_path .. "Jobs/job.lua"                ,"TurtleFleet/Jobs/job.lua" )
    get_file_from_github( git_path .. "Jobs/builder.lua"            ,"TurtleFleet/Jobs/builder.lua" )
    get_file_from_github( git_path .. "Jobs/cooker.lua"             ,"TurtleFleet/Jobs/cooker.lua" )
    get_file_from_github( git_path .. "Jobs/Miner.lua"              ,"TurtleFleet/Jobs/miner.lua" )
    get_file_from_github( git_path .. "Jobs/Miner.lua"              ,"TurtleFleet/Utils/visual.lua" )
    get_file_from_github( git_path .. "startup.lua"                 ,"startup" )

    rs.setAnalogueOutput( "back", 1 )
    os.sleep( 0.05 )
    rs.setAnalogueOutput( "back", 0 )
end

function get_file_from_github( url, file_path )
    local f = fs.open( file_path, "w" )
    local w, m = http.get( url )
    if w then
        f.write( w.readAll() )
        f.flush()
        f.close()
    else
        print( "Cant load '" .. url .. "' : " .. m )
    end
end

update()