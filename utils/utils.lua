-----------
-- Utils --
-----------
function get_center_x( size, total )
	total = total + total % 2
	return math.ceil( ( total - size ) / 2 )
end