---@diagnostic disable: duplicate-doc-field

---@class table
---@field contains function
local t = table

--- If the table contains the element.
---@param the_table table
---@param element any
---@return integer|false
function t.contains( the_table, element )
  for k, value in pairs( the_table ) do
    if value == element then return k end
  end
  return false
end

--- Add the content of a table to anothe one.
---@param main_table table
---@param table_to_add table
function t.insert_range( main_table, table_to_add )
  for _, item in ipairs( table_to_add ) do
    table.insert( main_table, item )
  end
end

--- Insert an element to the table if it's not already in it.
---@param the_table table
---@param element any
function t.insert_if_not_contains( the_table, element )
  if not t.contains( the_table, element ) then
    t.insert( the_table, element )
  end
end

return t