---@class Queue A queue.
---@field first integer The index of the first item.
---@field last integer The index of the last item.
---@field private items any[] The list of items.
local Queue = {}
Queue.__index = Queue

--- New queue object.
function Queue.new()
  local self = setmetatable( {}, Queue )
  self.first = 0
  self.last = -1
  self.items = {}
  return self
end

--- Add a new value in the queue.
---@param value any Value to add to the queue.
function Queue:add( value )
  -- Index of the new first.
  local first = self.first - 1
  -- Save the index.
  self.first = first
  -- Set the value at that index.
  self.items[ first ] = value
end

--- Pop the last value of the queue.
---@return unknown # The last item.
function Queue:pop()
  -- Get the index of the last value.
  local last = self.last
  -- If the first index is greater than the last... error.
  if self.first > last then CLogManager.log_error( "The queue is empty." ) end
  -- Get the value at the 'last' index.
  local value = self.items[ last ]
  -- Allow garbage collection
  self.items[ last ] = nil
  -- Save the new 'last' index.
  self.last = last - 1
  -- return the value.
  return value
end

--- Iterator usable in a for loop.
---@return function iterator The iterator function.
function Queue:iterator()
  local i = self.first - 1

  return function()
    i = i + 1
    if i <= self.last then return self.items[ i ] end
  end
end

--- Get the size of the queue.
---@return integer count The size of the queue.
function Queue:size()
  return self.last - self.first + 1
end

return Queue
