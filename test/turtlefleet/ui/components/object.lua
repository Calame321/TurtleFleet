return function()
  -- Base object
  local initialized = false

  local properties = {}
  local propertyConfig = {}

  local function defaultRule( typ )
    return function( self, value )
      local isValid = false
      -- If it's a string of types.
      if type( typ ) == "string" then
        local types = Utils.split_string( typ, "|" )
        for _, v in pairs( types ) do
          if type( value ) == v then isValid = true end
        end
      end
      -- If it's a table of types.
      if  type( typ ) == "table" then
        for _,v in pairs( typ ) do
          if v == value then isValid = true end
        end
      end
      -- If it's a color.
      if typ == "color" then
        if type( value ) == "string" then
          if colors[ value ] ~= nil then
            isValid = true
            value = colors[ value ]
          end
        else
          for _,v in pairs(colors)do
            if v == value then isValid = true end
          end
        end
      end
      -- If it's a character.
      if typ == "char" then
        if type( value ) == "string"  then
          if #value == 1 then isValid = true end
        end
      end
      -- Any type.
      if typ == "any" or value == nil or type( value ) == "function" then
        isValid = true
      end
      -- If it's string and the value is not a function.
      if typ == "string" and type( value ) ~= "function" then
        value = tostring( value )
        isValid = true
      end
      -- Error message if not valid.
      if not isValid then
        local t = type( value )
        if type( typ ) == "table"  then
          typ = table.concat( typ, ", " )
          t = value
        end
        error( self:getType() .. ": Invalid type for property! Expected " .. typ .. ", got " .. t )
      end

      return value
    end
  end

  local parent
  local object

  object = {
      init = function( self )
        if initialized then return false end
        initialized = true
        return true
      end,

      isType = function( self, typ )
        for _,v in pairs( properties[ "Type" ] ) do
          if v == typ then
            return true
          end
        end
        return false
      end,

      getTypes = function( self )
        return properties[ "Type" ]
      end,

      load = function( self )
      end,

      getProperty = function( self, name )
        local prop = properties[ name:gsub( "^%l", string.upper ) ]
        if type( prop ) == "function" then
          return prop()
        end
        return prop
      end,

      getProperties = function( self )
        local p = {}
        for k, v in pairs( properties ) do
          if type( v ) == "function" then
            p[ k ] = v()
          else
            p[ k ] = v
          end
        end
        return p
      end,

      setProperty = function( self, name, value, rule )
        name = name:gsub( "^%l", string.upper )
        if rule then
          value = rule( self, value )
        end
        properties[ name ] = value
        if self.updateDraw then
          self:updateDraw()
        end
        return self
      end,

      getPropertyConfig = function( self, name )
        return propertyConfig[ name ]
      end,

      addProperty = function( self, name, typ, defaultValue, readonly, setLogic, getLogic, alteredRule )
        name = name:gsub( "^%l", string.upper )
        propertyConfig[ name ] = { type=typ, defaultValue = defaultValue, readonly = readonly }
        if properties[ name ] ~= nil then
          error( "Property " .. name .. " in " .. self:getType() .. " already exists!" )
        end
        self:setProperty( name, defaultValue )

        object[ "get" .. name ] = function( self, ... )
          if self then
            local prop = self:getProperty( name )
            if getLogic then
              return getLogic( self, prop, ... )
            end
            return prop
          end
        end
        if not readonly then
          object[ "set" .. name ] = function( self, value, ... )
            if self then
              if setLogic then
                local modifiedVal = setLogic(self, value, ...)
                if modifiedVal then
                  value = modifiedVal
                end
              end
              self:setProperty( name, value, alteredRule ~= nil and alteredRule( typ ) or defaultRule( typ ) )
            end
            return self
          end
        end
        return self
      end,

      setParent = function(self, newParent, noRemove)
          if(noRemove)then parent = newParent return self end
          if (newParent.getType ~= nil and newParent:isType("Container")) then
              self:remove()
              newParent:addChild(self)
              parent = newParent
          end
          return self
      end,

      getParent = function(self)
          return parent
      end,

      enable = function(self)
          self:setProperty("Enabled", true)
          return self
      end,

      disable = function(self)
          self:setProperty("Enabled", false)
          return self
      end,

      isEnabled = function(self)
          return self:getProperty("Enabled")
      end,

      remove = function(self)
          if (parent ~= nil) then
              parent:removeChild(self)
          end
          self:updateDraw()
          return self
      end,

      getBaseFrame = function(self)
          if(parent~=nil)then
              return parent:getBaseFrame()
          end
          return self
      end,

      onEvent = function(self, ...)
          for _,v in pairs(table.pack(...))do
              if(type(v)=="function")then
                  self:registerEvent("other_event", v)
              end
          end
          return self
      end
  }

  object:addProperty("Z", "number", 1, false, function(self, value)
      if (parent ~= nil) then
          parent:updateZIndex(self, value)
          self:updateDraw()
      end
      return value
  end)
  object:addProperty( "Type", "string|table", {"Object"}, false,
    function( self, value )
      if type( value ) == "string" then
        table.insert( properties[ "Type" ], 1, value )
        return properties[ "Type" ]
      end
    end,

    function( self, _, depth )
        return properties[ "Type" ][ depth or 1 ]
    end
  )

  object:addProperty( "Enabled", "boolean", true )

  object.__index = object
  return object
end