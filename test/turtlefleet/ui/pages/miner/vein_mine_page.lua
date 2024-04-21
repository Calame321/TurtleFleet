--[[
function show_vein_mine_page()
  term.clear()
  term.setCursorPos( 1, 1 )
  print( "- Vein Mine -" )
  print( "This will mine all block specified that are connected by a side. (Diagonal dosen't work.)" )
  print()

  print( "Block to mine = ? (default = The block in front)")
  sleep( 0.2 )
  local input = read()
  if input == "" then
    local found_block, block_data = turtle.inspectDir( "forward" )
    if found_block then
      input = block_data.name
    end
  end

  miner.start_vein_mine( "forward", input )
  menu.show()
end
]]