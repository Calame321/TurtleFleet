local o = {}

-- Currently available task waiting for a turtle.
o.tasks = {}

-- Get the next task in the list.
function o.get_next_task()
  local next_task = nil
  for k, v in pairs( o.tasks ) do
    if v.status == "ready" then
      next_task = v
      break
    end
  end
  return next_task
end

-- Add a task to the queue.
function o.add_task( task )
  table.insert( o.tasks, task )
end

-- Remove a task from the list.
function o.remove_task( task_id )
  CLogManager.log_info( "Removing task id: " .. task_id )
  for k = 1, #o.tasks do
    if o.tasks[ k ].id == task_id then
      table.remove( o.tasks, k )
      return
    end
  end
end

-- If there is at least 1 task available.
function o.has_any()
  return #o.tasks > 0
end

-- Save the tasks in a file.
function o.dump()
  -- Not implemented.
end

-- If there is already a task to scout the chunk.
function o.is_scouting( chunk_pos )
  for k, v in pairs( o.tasks ) do
    if v.position.x == chunk_pos.x and v.position.z == chunk_pos.z then return true end
  end
  return false
end

return o
