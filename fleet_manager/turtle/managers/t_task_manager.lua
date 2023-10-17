local t = {}

t.current_task = nil

-- Set the current task.
function t.set_new_task( task )
  t.current_task = task
  TSettingsManager.set( "task", t.current_task )
  TLogManager.log_info( "Received a new task: " .. t.current_task.id .. "-" .. t.current_task.type )
end

-- report the task completion to the command center.
function t.report_task_completion( task )
  t.current_task.completed = true
  -- Send a message to the control center to indicate that the task is completed.
  TNetworkManager.send_message( { type = "task_completed",  turtle_id = os.computerID(), task = task } )
  -- Clear the task.
  t.current_task = nil
  -- Remove the saved task.
  TSettingsManager.unset( "task" )
end

-- Execute the current task if there is one.
function t.execute_task()
  if t.current_task == nil then return end

  if t.current_task.type == "scouting" then
    Scouting.execute( t.current_task )
  elseif t.current_task.type == "building" then
    Building.execute( t.current_task )
  elseif t.current_task.type == "return home" then
    ReturnHome.execute( t.current_task )
  end
end

return t