local o = {}

local FILE_NAME = ".settings"

-- Initialize the settings values.
function o.init()
  settings.load( FILE_NAME )

  -- The protocol used to communicate with the turtles.
  settings.define( "protocol", {
    description = "The protocol used to communicate with the turtles.",
    default = "fleet_protocol",
    type = "string"
  })

  -- The name of computer that coordinates the turtles.
  settings.define( "host_name", {
    description = "The name of computer that coordinates the turtles.",
    default = "command_center",
    type = "string"
  })

  -- The name of computer that coordinates the turtles.
  settings.define( "position", {
    description = "The position of the computer in the world.",
    default = { x = 48, y = 64, z = 91 },
    type = "table"
  })
end

-- Set and save a value in the settings file.
function o.set( key, value )
  -- Set the value.
  settings.set( key, value )
  -- Save the file.
  settings.save( FILE_NAME )
end

-- Get a value from the settings.
function o.get( key, value )
  return settings.get( key, value )
end

-- Unset a value in the settings and save de file.
function o.unset( key )
  -- Unset the value.
  settings.unset( key )
  -- Save the file.
  settings.save( FILE_NAME )
end

return o