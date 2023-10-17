extends Node

const CHUNK_SIZE = 16

var chunks_data = {}

func _ready():
	for i in range( -10, 10 ):
		for j in range( -10, 10 ):
			from_file( [ i, j ] )

func get_block( pos : Vector3i ) -> String:
	var chunk_pos = [ pos.x >> 4, pos.z >> 4 ]
	if chunks_data.has( chunk_pos ) and chunks_data[ chunk_pos ].blocks.has( pos ):
		return chunks_data[ chunk_pos ].blocks[ pos ]
	return "none"

# Load the chunk file based on the position.
func from_file( chunk_position ):
	if chunks_data.has( chunk_position ):
		return chunks_data[ chunk_position ]
	
	var file_name = "res://chunks/%s-%s.bin" % chunk_position
	if not FileAccess.file_exists( file_name ):
		return ChunkData.new( {} )
	
	var file = FileAccess.open( file_name, FileAccess.READ )
	
	# the mods name until 0xFF
	var mods = []
	var blocks = []
	var positions = {}
	var buffer = ""
	var step = 0
	while true:
		var byte = file.get_8()
		
		if step == 0:
			# Done with the mods
			if byte == 0xFF:
				mods.append( buffer )
				buffer = ""
				step += 1
			# String seperator |.
			elif byte == 0x7C:
				mods.append( buffer )
				buffer = ""
			else:
				buffer += char( byte )
		elif step == 1:
			# Done with the mods
			if byte == 0xFF:
				blocks.append( buffer )
				buffer = ""
				step += 1
				break
			# String seperator |.
			elif byte == 0x7C:
				blocks.append( buffer )
				buffer = ""
			# mod seperator :.
			elif byte == 0x3A:
				var mod_id = int( buffer )
				buffer = mods[ mod_id - 1 ] + ":"
			else:
				buffer += char( byte )
	
	while file.get_position() < file.get_length():
		# Blocks above 255.
		if step == 2:
			var x_z = file.get_8()
			var y = file.get_8()
			var block_id = file.get_8()
			
			if x_z == 0xFF and y == 0xFF and block_id == 0xFF:
				step += 1
			else:
				var z = x_z & 0x0F
				var x = x_z >> 4
				positions[ Vector3i( x + ( 16 * chunk_position[ 0 ] ), y + 256, z + ( 16 * chunk_position[ 1 ] ) ) ] = blocks[ block_id - 1 ]
		
		# Blocks below 255.
		elif step == 3:
			var x_z = file.get_8()
			var y = file.get_8()
			var block_id = file.get_8()
			
			if x_z == 0xFF and y == 0xFF and block_id == 0xFF:
				step += 1
			else:
				var z = x_z & 0x0F
				var x = x_z >> 4
				positions[ Vector3i( x + ( 16 * chunk_position[ 0 ] ), y, z + ( 16 * chunk_position[ 1 ] ) ) ] = blocks[ block_id - 1 ]
		
		# Air above 255.
		elif step == 4:
			var x_z = file.get_8()
			var y = file.get_8()
			
			if x_z == 0xFF and y == 0xFF:
				step += 1
			else:
				var z = x_z & 0x0F
				var x = x_z >> 4
				positions[ Vector3i( x + ( 16 * chunk_position[ 0 ] ), y + 256, z + ( 16 * chunk_position[ 1 ] ) ) ] = "other:air"
		
		# Air below 255.
		elif step == 5:
			var x_z = file.get_8()
			var y = file.get_8()
			
			if x_z == 0xFF and y == 0xFF:
				step += 1
			else:
				var z = x_z & 0x0F
				var x = x_z >> 4
				positions[ Vector3i( x + ( 16 * chunk_position[ 0 ] ), y, z + ( 16 * chunk_position[ 1 ] ) ) ] = "other:air"
	var chunk_data = ChunkData.new( positions )
	chunks_data[ chunk_position ] = chunk_data
	return chunk_data
