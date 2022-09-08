------------
-- config --
------------
package.path = package.path .. ';/turtlefleet/turtle/?.lua;/turtlefleet/turtle/jobs/?.lua'
local menu = require( "turtle_menu" )
local fleet = require( "fleet_mode" )

shell.run( "turtlefleet/turtle/advanced_turtle.lua" )
shell.run( "turtlefleet/turtle/pathfind.lua" )

---------
-- Map --
---------
local map = {}

function load_map()
  if not fs.exists( "map" ) then
    local file = fs.open( "map", "w" )
    file.close()
  end

  local f = fs.open( "map", "r" )
  local line = f.readLine()
  while line ~= nil do
    local l = mysplit( line )
    map_add( vector.new( l[1], l[2], l[3] ), l[4] )
  end
end

function save_map()
  local file = fs.open( "map", "w" )

  for x, kx in pairs( map ) do
    for y, ky in pairs( kx ) do
      for z, kz in pairs( ky ) do
        file.writeLine( tostring( x ) .. " " .. tostring( y ) .. " " .. tostring( z ) .. " " .. kz )
      end
    end
  end

  file.flush()
  file.close()
end

function map_remove( pos )
  if not map[pos.x] or not map[pos.x][pos.y] or not map[pos.x][pos.y][pos.z] then return end
  table.remove( map[pos.x][pos.y], pos.z )
end

function map_add( pos, block_name )
  -- Add X table if not exists.
  if not map[ pos.x ] then
    map[ pos.x ] = {}
  end

  -- Add Y Table if not exists.
  if not map[ pos.x ][ pos.y ] then
    map[ pos.x ][ pos.y ] = {}
  end

  -- Set the block name at the position.
  map[ pos.x ][ pos.y ][ pos.z ] = block_name

  print( block_name .. " added for " .. tostring( pos ) )
end

function map_get( pos )
  -- If a value is not set, return nil
  if not map[ pos.x ] or not map[ pos.x ][ pos.y ] or not map[ pos.x ][ pos.y ][ pos.z ] then
    return nil
  end

  return map[ pos.x ][ pos.y ][ pos.z ]
end

fleet.check_redstone_option()

load_map()
menu.show()