------------------
-- Menu top bar --
------------------

-- Main variable
local menuItem = {}
local txtColor = colors.white
local backgroundColor = colors.lightBlue
local height = 1
local nbMenu = 0

function getHeight()
	return height
end

function getPos( text )
	local _size = string.len( text ) + 2
	local count = nbMenu

	if count == 0 then
	   return { x = 1, y = 1, size = _size }
	end

	local _x = menuItem[ count ].pos.x + menuItem[ count ].pos.size
	local _y = 1
	
	return { x = _x, y = _y, size = _size }
end


function addMenuItem( menuName, text )
	if menuName == nil then
		error( "menuName cannot be nil." )
	end

	local newMenu = {}
	newMenu.menuName = menuName
	newMenu.text = text
	newMenu.show = false
	newMenu.subSize = 1
	newMenu.nbSub = 0
	newMenu.pos = getPos( text )
	table.insert( menuItem, newMenu )

	nbMenu = nbMenu + 1
end


function getParentIndex( parentName )
	for index, data in pairs( menuItem ) do
		if data.menuName == parentName then
			return index
		end
	end

	error( "parentName dosen't exist" )
end


function addSubItem( menuName, subName, text, func, checked, color, backgroundColor )
	if menuName == nil or subName == nil then
		error( "menuName and subName cannot be nil." )
	end

	local parentIndex = getParentIndex( menuName )

	if string.len( text ) > menuItem[ parentIndex ].subSize then
		menuItem[ parentIndex ].subSize = string.len( text )
	end

	newSub = {}
	newSub.subName = subName
	newSub.text = text or ""
	newSub.func = func
	newSub.checked = checked or false
	newSub.color = color or colors.white
	newSub.backgroundColor = backgroundColor or colors.blue
	table.insert( menuItem[ parentIndex ], newSub )
	
	menuItem[ parentIndex ].nbSub = menuItem[ parentIndex ].nbSub + 1
end


-- Draw the menu bar
function draw()
	local lastBgColor = term.getBackgroundColor()

	term.setBackgroundColor( backgroundColor )
	term.setTextColor( txtColor )
	local sizeX = term.getSize()
	
	paintutils.drawFilledBox( 1, 1, sizeX, height, backgroundColor )
	term.setCursorPos( 1, 1 )
	
	for index, data in pairs( menuItem ) do
		term.setCursorPos( data.pos.x, data.pos.y )
		write( " " .. data.text .. " " )

		if data.show then
			drawSubMenu( data )
		end
	end

	term.setBackgroundColor( lastBgColor )
end


-- Draw subMenu if clicked
function drawSubMenu( parentData )
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


function onClick( x, y )
	for index, data in pairs( menuItem ) do
		local s_x = data.pos.x
		local s_y = data.pos.y
		local e_x = data.pos.x + data.pos.size - 1
		local e_y = data.pos.y + height - 1

		if data.show then
			onSubClick( x, y, data )
		end

		menuItem[ index ].show = x >= s_x and x <= e_x and y >= s_y and y <= e_y
	end
end


function onSubClick( x, y, data )
	local i = 1
	while data[ i ] ~= nil do
		local s_x = data.pos.x
		local s_y = height + i
		local e_x = data.pos.x + data.pos.size
		local e_y = s_y

		if x >= s_x and x <= e_x and y >= s_y and y <= e_y then
			data[ i ].func()
			return
		end
		i = i + 1
	end
end


function clear()
	menuItem = {}
	nbMenu = 0
end