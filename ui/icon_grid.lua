---------------
-- Icon Grid --
---------------
local icon_grid = {}

icon_grid.icons = {}
icon_grid.grid_size = 11
icon_grid.grid_height = 8
icon_grid.start_y = 1

function icon_grid.set_start_y( value )
	icon_grid.start_y = value + 1
end

function icon_grid.add_icon( icon_name, text, func, icon )
	if icon_name == nil then
		error( "icon_name cannot be nil." )
	end

	local iconPath = "turtlefleet/img/" .. ( icon or "iconMissing" )
	
	local id = table.getn( icon_grid.icons ) + 1
	icon_grid.icons[ id ] = {}
	icon_grid.icons[ id ].icon_name = icon_name
	icon_grid.icons[ id ].text = text or "icon" .. id
	icon_grid.icons[ id ].func = func
	icon_grid.icons[ id ].icon = iconPath
end

function icon_grid.draw()
	local lastBgColor = term.getBackgroundColor()

	local gridX = 1
	local gridY = icon_grid.start_y
	local monX, monY = term.getSize()
	
	for i = 1, table.getn( icon_grid.icons ) do
		local imgX = utils.getCenterX( 6, icon_grid.grid_size )
		paintutils.drawImage( paintutils.loadImage( icon_grid.icons[ i ].icon ), gridX + imgX, gridY + 1 )

		--Center text
		local txtX = utils.getCenterX( string.len( icon_grid.icons[ i ].text ), icon_grid.grid_size )
		term.setCursorPos( gridX + txtX, gridY + 7 )
		write( icon_grid.icons[ i ].text )

		gridX = gridX + icon_grid.grid_size + 1

		if gridX + icon_grid.grid_size > monX then
			gridX = 1
			gridY = gridY + icon_grid.grid_height
		end
	end

	term.setBackgroundColor( lastBgColor )
end

return icon_grid