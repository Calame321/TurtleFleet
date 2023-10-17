-- The task manager object.
local t = {}

function t.loop()
  while true do
    os.sleep( 0.1 )
    t.distribute_task()
  end
end

-- Try to send a task to available turtles.
function t.distribute_task()
  -- Getting a task.
  local new_task = TaskRepository.get_next_task()

  -- No task, nothing to do.
  if new_task == nil then
    return
  end

  -- Getting an available turtle.
  local turtle = FleetManager.find_available_turtle()

  if turtle then
    -- Prepare the message.
    local msg = { type = "task", task = new_task }
    -- Log it.
    CLogManager.log_info( "Sent task '" .. new_task.id .. "-" .. msg.task.type .. "' to " .. turtle.name .. "." )
    -- Send the message to the turtle.
    CNetworkManager.send_message( turtle.id, msg )
    -- Set the task on the turtle instace.
    FleetManager.new_task( turtle, new_task )
    -- Set the task to assigned.
    new_task.status = "assigned"
  end
end

-- Generate a new task object.
function t.generate_task( type )
  -- Create the task.
  local task = Task:new( type )

  -- Configure the task.
  if type == "scouting" then
    local chunk = WorldManager.get_next_chunk_to_explore()
    -- Starting position of the task.
    task.position = vector.new( chunk.position.x, 0, chunk.position.z )
  elseif type == "return home" then
    local pos = CSettingsManager.get( "position" )
    pos.y = pos.y + 1
    task.position = pos
  end

  -- Save the task.
  TaskRepository.add_task( task )
end

-- When a turtle complete a task.
function t.task_completed( task )
  TaskRepository.remove_task( task.id )
end

return t