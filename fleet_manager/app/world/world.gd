class_name voxel_world extends Node3D

var cur_chunk = Vector3( 0, 0, 0 )
var chunk_scene = preload( "res://node_3d.tscn" )
var player_position = Vector3.ZERO
var chunks = {}

# This controls the render distance.
var render_distance = Vector2( 15, 15 )
var z_render_offset = 0

var loaded_chunks = []
var loaded_chunk_instances = []

var chunk_size = Vector2( 16, 16 )
var first_thead_finished = false
var world_generated = false

var thread

# This script will place and add blocks and objects
# it will also update the blocks dictionary in each chunk
# and create/delete chunks on the fly.

func _ready():
	load_chunks_around_player( null )
	#thread = Thread.new()
	#thread.start( self, "load_chunks_around_player", null )

func get_chunk_coordinate( vec3 : Vector3 ):
	var cur_chunk = Vector2( floor( vec3.x / BlockTypes.CHUNK_SIZE ), floor( vec3.z / BlockTypes.CHUNK_SIZE ) )
	return cur_chunk

func update_player_chunk( new_pos ):
	player_position = new_pos
	if first_thead_finished:
		if thread != null and !thread.is_active():
			thread = Thread.new()
			thread.start( load_chunks_around_player.bind( null ) )

func load_chunks_around_player( data ):
	var player_global_pos = %player.position
	var player_pos = get_chunk_coordinate( player_global_pos )
	var new_chunks_to_load = []
	#%Label.text = str(Vector3(3,3,3))
	
	# Load chunk data.
	for i in range( -( render_distance.x - 1 ) / 2, ( render_distance.x + 1 ) / 2 ):
		for j in range( -( render_distance.y - 1 ) / 2, ( render_distance.y + 1 ) / 2 ):
			var chunk_key = [ player_position.x + i, player_position.y + j - z_render_offset ]
			var chunk_data = TerrainGenerator.from_file( chunk_key )
			
			if not chunks.has( chunk_key ):
				chunks[ chunk_key ] = chunk_data
			chunks[ chunk_key ] = chunk_data
			new_chunks_to_load.append( chunk_key )
	
	# Add new chunks.
	var cur_loaded = loaded_chunks
	for chunk_key in new_chunks_to_load:
		if loaded_chunks.find( chunk_key ) == -1:
			var new_chunk = chunk_scene.instantiate()
			new_chunk.name = "%s-%s" % chunk_key
			new_chunk.data = chunks[ chunk_key ]
			%chunk_container.add_child( new_chunk, true )
			new_chunk.update()
			loaded_chunks.append( chunk_key )
			loaded_chunk_instances.append( new_chunk )
	
	# Remove old chunk.
	for chunk_key in cur_loaded:
		if new_chunks_to_load.find( chunk_key ) == -1:
			var key = loaded_chunks.find( chunk_key )
			loaded_chunks.erase( chunk_key )
			var chunk = loaded_chunk_instances[ key ]
			chunk.queue_free()
			loaded_chunk_instances.remove( key )
	#call_deferred("finished_current_thread")
	finished_current_thread()

func finished_current_thread():
	#if thread.is_active():
	#	thread.wait_to_finish()
	first_thead_finished = true
	world_generated = true

func _exit_tree():
	if thread:
		thread.wait_to_finish()

func _input( event ):
	if event is InputEventKey:
		if event.keycode == KEY_R and event.pressed:
			get_tree().reload_current_scene()
