-- Install the Turtle Fleet Software --
local files = fs.list( "/disk" )

for k, v in pairs( files ) do
  if v ~= "startup.lua" then
    if v == "main_startup.lua" then
      fs.delete( "startup.lua" )
      fs.copy( "/disk/" .. v, "startup.lua" )
    else
      fs.delete( v )
      fs.copy( "/disk/" .. v, v )
    end
  end
end

print( "Install Done!" )

-- Place the next turtle for installation.
turtle.select( 1 )
if turtle.suck( 1 ) or turtle.inspectUp() then
  -- make sure it's a turtle.
  local item = turtle.getItemDetail()
  if not string.find( item.name, "turtle" ) then return end

  turtle.select( 2 )
  turtle.digUp()

  if not turtle.up() and turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel() == 0 then
    print( "place some coal in slot 3 please.")

    local item_data = turtle.getItemDetail( 3 )
    while item_data == nil or ( item_data.name ~= "minecraft:coal" and item_data.name ~= "minecraft:charcoal" ) do
      os.sleep( 1 )
      item_data = turtle.getItemDetail( 3 )
    end

    turtle.select( 3 )
    turtle.refuel( 1 )
    turtle.up()
    turtle.select( 2 )
  end

  turtle.drop()
  turtle.select( 1 )
  turtle.placeDown()
  os.sleep( 0.1 )
  peripheral.call( "bottom", "turnOn" )
  print( "Drop Turtle Done!" )
end
