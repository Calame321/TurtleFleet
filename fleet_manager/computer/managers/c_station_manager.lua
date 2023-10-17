---@class StationManager
---@field stations_data table[] The data for the different type of stations.
---@field stations Station[] All the known stations in the world.
local o = {}

local STATION_FOLDER = "data/stations"

o.stations_data = {}
o.stations = {}

function o.load_data()
  local mods = fs.list( STATION_FOLDER )
  for i = 1, #mods do
    local station_files = fs.list( STATION_FOLDER .. "/" .. mods[ i ] )
    for j = 1, #station_files do
      local f = fs.open( STATION_FOLDER .. "/" .. mods[ i ] .. "/" .. station_files[ j ], "r" )
      local content = f.readAll()
      local station_json = textutils.unserialiseJSON( content )
      f.close()
      local resources = {}
      for index, value in ipairs(t) do
        
      end
    end
  end
end

return o