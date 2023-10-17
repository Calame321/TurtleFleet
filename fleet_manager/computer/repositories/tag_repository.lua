require( "models.tag" )
table = require( "other.table_extension" )

local o = {}

o.tags = {}

local TAG_FOLDER = "data/tags"

--- Load all tags.
function o.load_all()
  local main_mods = fs.list( TAG_FOLDER )
  -- For all mods folder.
  for m = 1, #main_mods do
    local mod_folder = TAG_FOLDER .. "/" .. main_mods[ m ]
    local mods = fs.list( mod_folder )
    -- For all mods they have tags for.
    for i = 1, #mods do
      local mod = mods[ i ]
      local tag_files = fs.list( mod_folder .. "/" .. mod )
      -- For each file or folder in a sub_mod.
      for j = 1, #tag_files do
        local file = tag_files[ j ]
        -- If it's a json file. load it.
        local path = mod_folder .. "/" .. mod .. "/" .. tag_files[ j ]
        if file:find( "%.json" ) then
          local tag_name = mod .. ":" .. string.gmatch( file, "(.+)%.json" )()
          o.load_tag( path, mod, file, tag_name )
        else
          -- If it's a folder. load the content.
          local sub_files = fs.list( path )
          for s = 1, #sub_files do
            local sub_file = sub_files[ s ]
            local tag_name = mod .. ":" .. file .. "/" .. string.gmatch( sub_file, "(.+)%.json" )()
            o.load_tag( path .. "/" .. sub_file, mod, sub_file, tag_name )
          end
        end
      end
    end
  end
  -- Bring all the # in the tag.
  for k, v in pairs( o.tags ) do
    o.tags[ k ] = o.set_sub_tags( v )
  end
end

--- Return all the # collapsed to the item names.
---@param main_tag Tag
---@return Tag
function o.set_sub_tags( main_tag )
  local new_tag = {}
  for i, tag_name in ipairs( main_tag ) do
    if tag_name:sub( 1, 1 ) == "#" then
      local sub_tag = o.tags[ tag_name:sub( 2 ) ]
      local t = o.set_sub_tags( sub_tag )
      table.insert_range( new_tag, t )
    else
      table.insert( new_tag, tag_name )
    end
  end
  return new_tag
end

function o.load_tag( file_path, mod, file, tag_name )
  o.tags[ tag_name ] = o.tags[ tag_name ] or {}
  local f = fs.open( file_path, "r" )
  local content = f.readAll()
  f.close()
  local data = textutils.unserialiseJSON( content )
  for _, item in ipairs( data.values ) do
    table.insert_if_not_contains( o.tags[ tag_name ], item )
  end
end

return o
-- t = require("repositories.tag_repository")