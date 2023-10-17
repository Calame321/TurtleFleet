local l = {}

l.ERROR = 1
l.WARNING = 2
l.INFO = 3
l.DEBUG = 4
l.TRACE = 5

l.log_type_names = {
  [ l.ERROR ] = "Error",
  [ l.WARNING ] = "Warning",
  [ l.INFO ] = "Info",
  [ l.DEBUG ] = "Debug",
  [ l.TRACE ] = "Trace"
}

l.colors = {
  [ l.ERROR ] = colors.red,
  [ l.WARNING ] = colors.yellow,
  [ l.INFO ] = colors.lightBlue,
  [ l.DEBUG ] = colors.lime,
  [ l.TRACE ] = colors.lightGray
}

-- The log's level to display.
l.log_level = l.TRACE

-- All the logs.
l.logs = Queue.new()

-- Max amount of logs to keep.
l.max_logs = 8

-- Log an error message.
function l.log_error( message )
  if l.log_level < l.ERROR then return end
  local new_log = Log.new( message, l.ERROR )
  l.add( new_log )
end

-- Log a warning message.
function l.log_warning( message )
  if l.log_level < l.WARNING then return end
  local new_log = Log.new( message, l.WARNING )
  l.add( new_log )
end

-- Log an information message.
function l.log_info( message )
  if l.log_level < l.INFO then return end
  local new_log = Log.new( message, l.INFO )
  l.add( new_log )
end

-- Log a debug message.
function l.log_debug( message )
  if l.log_level < l.DEBUG then return end
  local new_log = Log.new( message, l.DEBUG )
  l.add( new_log )
end

-- Log a trace message.
function l.log_trace( message )
  if l.log_level < l.TRACE then return end
  local new_log = Log.new( message, l.TRACE )
  l.add( new_log )
end

---@package
--- Add the log to the queue.
---@param new_log Log
function l.add( new_log )
  -- Delete the log file if too big.
  if fs.exists( "data/logs" ) and fs.getSize( "data/logs" ) > 50000 then
    fs.delete( "data/logs" )
  end
  -- Add the log to the file.
  local file = fs.open( "data/logs", "a" )
  file.writeLine( l.log_type_names[ new_log.type ] .. " : " .. new_log.message )
  file.close()
  -- Add the log to the queue.
  l.logs:add( new_log )
  if l.logs:size() > l.max_logs then l.logs:pop() end
end

return l