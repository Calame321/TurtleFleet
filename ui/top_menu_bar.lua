------------------
-- Menu top bar --
------------------
local top_menu_bar = {}

-- Main variable
top_menu_bar.menu_item = {}
top_menu_bar.txt_color = colors.white
top_menu_bar.background_color = colors.lightBlue
top_menu_bar.height = 1
top_menu_bar.total_menu = 0


function top_menu_bar.get_position( text )
	local _size = string.len( text ) + 2
	local count = top_menu_bar.total_menu

	if count == 0 then
	   return { x = 1, y = 1, size = _size }
	end

	local _x = top_menu_bar.menu_item[ count ].pos.x + top_menu_bar.menu_item[ count ].pos.size
	local _y = 1
	
	return { x = _x, y = _y, size = _size }
end


function top_menu_bar.add_menu_item( menu_name, text )
	if menu_name == nil then
		error( "menu_name cannot be nil." )
	end

	local newMenu = {}
	newMenu.menu_name = menu_name
	newMenu.text = text
	newMenu.show = false
	newMenu.subSize = 1
	newMenu.nbSub = 0
	newMenu.pos = top_menu_bar.get_position( text )
	table.insert( top_menu_bar.menu_item, newMenu )

	top_menu_bar.total_menu = top_menu_bar.total_menu + 1
end


function top_menu_bar.getParentIndex( parentName )
	for index, data in pairs( top_menu_bar.menu_item ) do
		if data.menu_name == parentName then
			return index
		end
	end

	error( "parentName dosen't exist" )
end


function addSubItem( menu_name, subName, text, func, checked, color, background_color )
	if menu_name == nil or subName == nil then
		error( "menu_name and subName cannot be nil." )
	end

	local parentIndex = top_menu_bar.getParentIndex( menu_name )

	if string.len( text ) > top_menu_bar.menu_item[ parentIndex ].subSize then
		top_menu_bar.menu_item[ parentIndex ].subSize = string.len( text )
	end

	newSub = {}
	newSub.subName = subName
	newSub.text = text or ""
	newSub.func = func
	newSub.checked = checked or false
	newSub.color = color or colors.white
	newSub.top_menu_bar.background_color = background_color or colors.blue
	table.insert( top_menu_bar.menu_item[ parentIndex ], newSub )
	
	top_menu_bar.menu_item[ parentIndex ].nbSub = top_menu_bar.menu_item[ parentIndex ].nbSub + 1
end


-- Draw the menu bar
function top_menu_bar.draw()
	local lastBgColor = term.getBackgroundColor()

	term.setBackgroundColor( top_menu_bar.background_color )
	term.setTextColor( top_menu_bar.txt_color )
	local sizeX = term.getSize()
	
	paintutils.drawFilledBox( 1, 1, sizeX, top_menu_bar.height, top_menu_bar.background_color )
	term.setCursorPos( 1, 1 )
	
	for index, data in pairs( top_menu_bar.menu_item ) do
		term.setCursorPos( data.pos.x, data.pos.y )
		write( " " .. data.text .. " " )

		if data.show then
			top_menu_bar.drawSubMenu( data )
		end
	end

	term.settop_menu_bar.background_color( lastBgColor )
end


-- Draw subMenu if clicked
function top_menu_bar.drawSubMenu( parentData )
	local lastBgColor = term.getBackgroundColor()

	paintutils.drawFilledBox( parentData.pos.x, parentData.pos.y + 1, parentData.pos.x + parentData.subSize + 1, parentData.nbSub + 1, colors.blue )

	local i = 1
	while parentData[ i ] ~= nil do
		term.setCursorPos( parentData.pos.x, parentData.pos.y + i )
		write( " " .. parentData[ i ].text )
		i = i + 1
	end

	term.setBackgroundColor( lastBgColor )
end


function top_menu_bar.onClick( x, y )
	for index, data in pairs( top_menu_bar.menu_item ) do
		local s_x = data.pos.x
		local s_y = data.pos.y
		local e_x = data.pos.x + data.pos.size - 1
		local e_y = data.pos.y + top_menu_bar.height - 1

		if data.show then
			top_menu_bar.onSubClick( x, y, data )
		end

		top_menu_bar.menu_item[ index ].show = x >= s_x and x <= e_x and y >= s_y and y <= e_y
	end
end


function top_menu_bar.onSubClick( x, y, data )
	local i = 1
	while data[ i ] ~= nil do
		local s_x = data.pos.x
		local s_y = top_menu_bar.height + i
		local e_x = data.pos.x + data.pos.size
		local e_y = s_y

		if x >= s_x and x <= e_x and y >= s_y and y <= e_y then
			data[ i ].func()
			return
		end
		i = i + 1
	end
end


function top_menu_bar.clear()
	top_menu_bar.menu_item = {}
	top_menu_bar.total_menu = 0
end

return top_menu_bar