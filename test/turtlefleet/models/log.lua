---@diagnostic disable: duplicate-doc-field

---@class Log A log message.
---@field message string The message.
---@field type integer The type code of the log.
Log = {}
Log.__index = Log

--- Derived class method new
---@param message string
---@param type integer
---@return Log # Created Log object.
function Log.new( message, type )
   local self = setmetatable( {}, Log )
   self.message = message or "Empty..."
   self.type = type or 1
   return self
end

return Log