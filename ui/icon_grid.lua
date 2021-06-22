---------------
-- Icon Grid --
---------------

local icons = {}
local gridSize = 11
local gridHeight = 8
local startY = 1

function setStartY( value )
	startY = value + 1
end

function addIcon( iconName, text, func, icon )
	if iconName == nil then
		error( "iconName cannot be nil." )
	end

	local iconPath = "turtlefleet/img/" .. ( icon or "iconMissing" )
	
	local id = table.getn( icons ) + 1
	icons[ id ] = {}
	icons[ id ].iconName = iconName
	icons[ id ].text = text or "icon" .. id
	icons[ id ].func = func
	icons[ id ].icon = iconPath
end

function draw()
	local lastBgColor = term.getBackgroundColor()

	local gridX = 1
	local gridY = startY
	local monX, monY = term.getSize()
	
	for i = 1, table.getn( icons ) do
		local imgX = utils.getCenterX( 6, gridSize )
		paintutils.drawImage( paintutils.loadImage( icons[ i ].icon ), gridX + imgX, gridY + 1 )

		--Center text
		local txtX = utils.getCenterX( string.len( icons[ i ].text ), gridSize )
		term.setCursorPos( gridX + txtX, gridY + 7 )
		write( icons[ i ].text )

		gridX = gridX + gridSize + 1

		if gridX + gridSize > monX then
			gridX = 1
			gridY = gridY + gridHeight
		end
	end

	term.setBackgroundColor( lastBgColor )
end