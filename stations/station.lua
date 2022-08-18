-- A station object.
station = {
  -- type = mine, farm, smeltery, warehouse, etc.
  type = "",
  -- sub_type = "minecraft:oak_wood", "minecraft:sugar_cane", etc.
  sub_type = "",
  -- position of the output chest ( if any ).
  output_pos = vector.new( 0, 0, 0 ),
  -- position of the input chest ( if any ).
  input_pos = vector.new( 0, 0, 0 ),
  -- position of the fuel chest ( if any ).
  fuel_pos = vector.new( 0, 0, 0 ),
  -- the number of turtle currently working there.
  workers = 0,
  -- max number of turtle that can work there.
  max_worker = 1,
  -- if the station has been built and is ready to operate.
  is_set_up = false,
  -- A list of erssources needed to build the station.
  res_to_build = {},
}

function station:new( o )
  o = o or {}
  setmetatable( o, self )
  self.__index = self
  return o
end

function station:build()
end

function station:start_work()
  if workers >= max_worker then
    print( "can't work there. It's full.")
    return false
  end

  workers = workers + 1
  return true
end

return station