-- Install the Turtle Fleet Software --
local files = fs.list( "/disk" )

for k, v in pairs( files ) do
  if v ~= "startup" then
    if v == "main_startup" then
      fs.delete( "startup" )
      fs.copy( "/disk/" .. v, "startup" )
    else
      fs.delete( v )
      fs.copy( "/disk/" .. v, v )
    end
  end
end

print( "Install Done!" )

turtle.select( 1 )
if turtle.suck( 1 ) or turtle.inspectUp() then
  turtle.select( 2 )
  turtle.digUp()

  if not turtle.up() then
    print( "place some coal in slot 3 please.")

    local item_data = turtle.getItemDetail( 3 )
    while item_data == nil or ( item_data.name ~= "minecraft:coal" and item_data.name ~= "minecraft:charcoal" ) do
      if item_data ~= nil then
        print( item_data.name )
      end
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
