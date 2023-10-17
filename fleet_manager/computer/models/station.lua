---@class Station Used to store data about the different stations that can be built.
---@field type string The type of station.
---@field position vector The position of the station in the world.
---@field status string The current status of the station.
Station = {}
Station.__index = Station

--- Create a new recipe.
---@return Station
function Station.new( type, position )
  local self = setmetatable( {}, Station )
  self.type = type
  self.position = position
  self.status = "building"
  return self
end

return Station