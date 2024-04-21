local ComponentBase = require( "turtlefleet.ui.components.component_base" )
local TextInput = require( "turtlefleet.ui.components.text_input" )
local ListInput = require( "turtlefleet.ui.components.list_input" )
local Panel = require( "turtlefleet.ui.components.panel" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )

---@class ItemList
---@field text_input TextInput
---@field item_source_selector Selector
---@field list_input ListInput
---@field back_btn Label The parent's back button so we can disable it.
local ItemList = Panel:inherit()
ItemList.__index = ItemList

function ItemList.initialize( self, x, y, w, h )
  Panel.initialize( self, x or 16, y or 2, w or 24, h or 12 )
  self.text_input = TextInput:new( 1, 2, self.w )
  self.item_source_selector = Selector:new()
  self.list_input = ListInput:new( 1, 3, self.w, 7 )
  self.back_btn = nil
  self.data_added = function() end

  self
    :add_option( Label:new( " + Text box", 2, 3 ):set_func( self:on_add_to_filter_clicked() ) )
    :add_component( self.item_source_selector )
    :add_component( Label:new( "Item name:", 1, 1 ) )
    :add_component( self.text_input:set_confirmed( self:on_text_confirmed() ):on_focus_changed( self:on_textbox_focus_changed() ) )
    :add_component( self.list_input:on_data_added( self:on_list_data_added() ) )
end

function ItemList:clear()
  self.text_input:clear()
  self.list_input:clear()
end

function ItemList.enable( self )
  ComponentBase.enable( self )
  self.text_input:set_focus( true )
  self:draw()
end

function ItemList.disable( self )
  ComponentBase.disable( self )
  self.text_input:set_focus( false )
  self.item_source_selector:set_focus( false )
  self:draw()
end

function ItemList:set_back_btn( btn )
  self.back_btn = btn
  return self
end

function ItemList:set_data( data )
  self.list_input:set_data( data )
end

--- Function to call when data is added to the list.
function ItemList:on_data_added( func )
  self.data_added = func
  return self
end

function ItemList:on_list_data_added()
  return function()
    self.data_added( self.list_input.data )
  end
end

--- When the textbox is confirmed with 'enter'.
function ItemList:on_text_confirmed()
  return function()
    self.text_input:set_focus( false )
    self.item_source_selector:set_focus( true )
  end
end

--- Add the textbox content to the list.
function ItemList:on_add_to_filter_clicked()
  return function()
    local text = self.text_input.text
    if text == "" then
      self.text_input:set_focus( true )
      self.item_source_selector:set_focus( false )
    else
      self.list_input:add_data( text )
      self.text_input:clear()
    end
  end
end

--- Directly add text to the list.
---@param text string
function ItemList:add_data( text )
  self.list_input:add_data( text )
  self.text_input:clear()
end

--- Add a new source for data.
---@param label_option Label
---@return ItemList
function ItemList:add_option( label_option )
  self.item_source_selector:add_component( label_option )
  self.list_input:set_y( 3 + #self.item_source_selector.components )
  return self
end

function ItemList:on_textbox_focus_changed()
  return function( has_focus )
    if self.back_btn == nil then return end
    if has_focus then
      self.back_btn:disable()
    else
      self.back_btn:enable()
    end
    self.back_btn:draw()
  end
end

return ItemList