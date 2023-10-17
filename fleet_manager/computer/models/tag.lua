require( "models.class" )

---@class Tag
---@field name string
---@field item_names string[]
Tag = Class()

--- Tag constructor.
---@param name any
---@param item_names any
function Tag:ctor( name, item_names )
  self.name = name
  self.item_names = item_names
end