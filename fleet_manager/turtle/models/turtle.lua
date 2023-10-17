Turtle = {}
Turtle.__index = Turtle

---Turtle class constructor.
---@return Turtle # The turtle's data object.
function Turtle.new()
  local self = setmetatable( {}, Turtle )
  self.id = os.computerID()
  self.name = os.computerLabel()
  self.x = 0
  self.y = 0
  self.z = 0
  -- -1: WEST, 1: EAST
  self.dx = 0
  -- -1: NORTH, 1: SOUTH
  self.dz = 0
  self.status = "idle"
  self.task = nil
  if term.isColor() then self.max_fuel = 100000 else self.max_fuel = 20000 end
  self.equpment_left = nil
  self.equpment_right = nil
  self.position_acuracy = "bad"
  return self
end

--- Load the data from the settings file.
function Turtle:load_settings()
  term.setCursorPos( 5, 5 )
  term.write( "Loading settings..." )
  local pos = TSettingsManager.get( "position" )
  self.x, self.y, self.z = pos.x, pos.y, pos.z
  local face = TSettingsManager.get( "facing" )
  self.dx, self.dz = face.dx, face.dz
  if self.x == 0 and self.y == 0 and self.z == 0 or ( self.dx == 0 and self.dz == 0 ) then self.position_acuracy = "bad" else self.position_acuracy = "good" end
  self.equpment_left = TSettingsManager.get( "equpment_left" )
  self.equpment_right = TSettingsManager.get( "equpment_right" )
  self.slots = TSettingsManager.get( "slots" )
  term.clear()
end

--- Set the data that are still nil or invalid.
function Turtle:set_missing()
  term.setCursorPos( 5, 5 )
  term.write( "Cheking equipment..." )
  if self.equpment_left == nil then
    self.equpment_left = turtle.get_eqipment( turtle.LEFT )
    TSettingsManager.set( "equpment_left", self.equpment_left )
  end
  if self.equpment_right == nil then
    self.equpment_right = turtle.get_eqipment( turtle.RIGHT )
    TSettingsManager.set( "equpment_right", self.equpment_right )
  end
  term.clear()
end

---The position of the turtle as a vector.
---@return vector
function Turtle:position()
  return vector.new( self.x, self.y, self.z )
end

--- Get the direction the turtle is facing.
---@return integer|nil # NORTH, WEST, EAST, SOUTH, nil
function Turtle:facing()
  if self.dz == -1 and self.dx == 0 then return turtle.NORTH
  elseif self.dz == 0 and self.dx == -1 then return turtle.WEST
  elseif self.dz == 0 and self.dx == 1 then return turtle.EAST
  elseif self.dz == 1 and self.dx == 0 then return turtle.SOUTH
  end
  return nil
end

--- Change the position of the turtle.
function Turtle:forward() self.x = self.x + self.dx; self.z = self.z + self.dz; TSettingsManager.save_position() end
function Turtle:back() self.x = self.x - self.dx; self.z = self.z - self.dz; TSettingsManager.save_position() end
function Turtle:down() self.y = self.y - 1; TSettingsManager.save_position() end
function Turtle:up() self.y = self.y + 1; TSettingsManager.save_position() end
function Turtle:turnRight() self.dx, self.dz = -self.dz, self.dx; TSettingsManager.save_facing() end
function Turtle:turnLeft() self.dx, self.dz = self.dz, -self.dx; TSettingsManager.save_facing() end

--- Set the slots data.
function Turtle:set_inventory()
  self.slots = turtle.get_slots()
end

return Turtle