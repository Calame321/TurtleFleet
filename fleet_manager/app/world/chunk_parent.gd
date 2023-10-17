extends Node3D

var chunks : Dictionary = {}

var chunk_size = Vector2( 16, 16 )

# Returns the chunk coordinate, which is a vector2. (no vertical chunks)
func get_chunk_coordinate( vec3 : Vector3 ):
	var cur_chunk = Vector2( floor( vec3.x / chunk_size.x ), floor( vec3.z / chunk_size.y ) )
	return cur_chunk
