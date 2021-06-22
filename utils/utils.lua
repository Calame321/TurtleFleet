function getCenterX( size, total )
	total = total + total % 2
	return math.ceil( ( total - size ) / 2 )
end