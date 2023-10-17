---@class Turtle The class for storing turtle data in the command center.
---@field id integer The id of the turtle.
---@field name string The display name of the turtle.
---@field status string The current status of the turtle.
---@field x integer The x position of the turtle.
---@field y integer The y position of the turtle.
---@field z integer The z position of the turtle.
---@field task Task|nil The current task of the turtle.
---@field is_advanced boolean If it's an advanced turtle.
---@field max_fuel integer The turtle max fuel level.
---@field fuel_level integer The current turtle's fuel level.
---@field equpment_left string|nil The left equipment.
---@field equpment_right string|nil The right equipment.
---@field dx 1|0|-1 If the turtle is facing 1 east or -1 west.
---@field dz 1|0|-1 If the turtle is facing 1 south or -1 north.
---@field slots table<integer, { item: string|nil, quantity: integer}>
---@field position_acuracy "bad"|"good"|"perfect" If = 0, 0, 0: bad. If from settings: good. if from gps: perfect.
Turtle = {}
Turtle.__index = Turtle

---Turtle class constructor.
---@param data table Data from a turtle's message or loaded from file.
---@return Turtle # The turtle's data object.
function Turtle.new( data )
  local self = setmetatable( {}, Turtle )
  self.id = data.id or 0
  self.name = data.name or "none"
  self.x = data.x or 0
  self.y = data.y or 0
  self.z = data.z or 0
  self.dx = data.dx or 0
  self.dz = data.dz or 0
  self.status = data.status or "idle"
  self.task = data.task or nil
  self.is_advanced = false
  if self.is_advanced then self.max_fuel = 100000 else self.max_fuel = 20000 end
  self.fuel_level = data.fuel_level or 0
  self.equpment_left = data.equpment_left or nil
  self.equpment_right = data.equpment_right or nil
  -- Set inventory slots.
  self.slots = {}
  for i = 1, 16 do
    if data.slots[ i ] and data.slots[ i ].item then
      self.slots[ i ] = data.slots[ i ]
    else
      self.slots[ i ] = { item = nil, quantity = 0 }
    end
  end
  return self
end

---The position of the turtle as a vector.
---@return vector
function Turtle:position()
  return vector.new( self.x, self.y, self.z )
end

return Turtle