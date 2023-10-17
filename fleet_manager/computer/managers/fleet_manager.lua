-- The turtle manager object.
local t = {}

t.SAVE_FOLDER = "data/turtles/"

-- Currently connected turtles.
t.turtles = {}

--- Ping the turtles to check if they are still connected.
function t.ping_turtles()
  while true do
    sleep( 10 )
    for _, turtle in pairs( t.turtles ) do
      if CNetworkManager.send_ping( turtle.id ) == false then
        turtle.status = "disconnected"
      end
    end
  end
end

--- Get the turtle by it's id.
---@param turtle_id integer
---@return Turtle|nil
function t.get_turtle_by_id( turtle_id )
  for _, turtle in pairs( t.turtles ) do
    if turtle.id == turtle_id then
        return turtle
    end
  end
  return nil
end

-- Function to check for available turtles.
function t.find_available_turtle()
  for id, turtle in pairs( t.turtles ) do
    if turtle.status == "idle" then
      return turtle
    end
  end
  return nil
end

-- Add a turtle to the list so it can receive tasks.
---@param data Turtle
function t.turtle_connected( data )
  local old_turtle = t.get_turtle_by_id( data.id )
  local turtle = Turtle.new( data )

  if old_turtle then
    CLogManager.log_info( turtle.name .. " reconnected." )
    if turtle.status == "disconnected" then
      -- If it had a task, it's busy.
      if turtle.task then turtle.status = "busy" else turtle.status = "idle" end
    end
  else
    table.insert( t.turtles, turtle )
    CLogManager.log_info( "New turtle connected: " .. data.name )
  end

  t.save( turtle )
end

--- Set the inventory of the turtle.
---@param sender integer
---@param slots { item: string, quantity: integer }[]
function t.set_inventory( sender, slots )
  local turtle = t.get_turtle_by_id( sender )
  if turtle == nil then
    CLogManager.log_error( "Can't set the inventory of turtle id: " .. sender )
    return
  end
  for i in ipairs( slots ) do
    turtle.slots[ i ].item = slots[ i ].item
    turtle.slots[ i ].quantity = slots[ i ].quantity
  end
  t.save( turtle )
end

-- Set the turtle to idle when it's task is done.
function t.task_completed( id )
  local turtle = t.get_turtle_by_id( id )
  turtle.status = "idle"
  turtle.task = nil

  if turtle == nil then
    return
  end

  CLogManager.log_info( turtle.name .. " completed his task." )
end

--- Set the task to the turtle.
---@param turtle Turtle
---@param task Task
function t.new_task( turtle, task )
  turtle.task = task
  turtle.status = "busy"
end

--- Save a turtle in a file.
---@param turtle Turtle
function t.save( turtle )
  if not fs.exists( t.SAVE_FOLDER ) then fs.makeDir( t.SAVE_FOLDER ) end
  local f = fs.open( t.SAVE_FOLDER .. turtle.id .. ".txt", "w" )
  f.write( "return " .. Pretty.render( Pretty.pretty( turtle ) ) )
  f.close()
end

--- Load the turtles' data.
function t.load_all()
  if not fs.exists( t.SAVE_FOLDER ) then fs.makeDir( t.SAVE_FOLDER ) end
  local files = fs.list( t.SAVE_FOLDER )
  for i = 1, #files, 1 do
    local f = fs.open( t.SAVE_FOLDER .. files[ i ], "r" )
    local turtle = load( f.readAll() )()
    table.insert( t.turtles, Turtle.new( turtle ) )
    f.close()
  end
end

return t