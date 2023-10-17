extends Node3D

var shader = preload( "res://animated.gdshader" )

var materials = {}
var multi_meshes = {}
var all_mesh_positions = {}
# { block_direction, { position } }

# block that consist of 2 face in a x.
const x_blocks = [
	"minecraft:grass",
	"minecraft:tall_grass_top",
	"minecraft:tall_grass_bottom",
	"minecraft:poppy",
	"minecraft:dandelion",
	"minecraft:tall_seagrass_top",
	"minecraft:tall_seagrass_bottom",
	"minecraft:seagrass",
]

# Vertices of a cube.
const vertices = [
	Vector3( 0, 0, 0 ), # Right, Bottom, Back,    0
	Vector3( 1, 0, 0 ), # Left,  Bottom, Back,    1
	Vector3( 0, 1, 0 ), # Right, Top,    Back,    2
	Vector3( 1, 1, 0 ), # Left,  Top,    Back,    3
	Vector3( 0, 0, 1 ), # Right, Bottom, Forward, 4
	Vector3( 1, 0, 1 ), # Left,  Bottom, Forward, 5
	Vector3( 0, 1, 1 ), # Right, Top,    Forward, 6
	Vector3( 1, 1, 1 )  # Left,  Top,    Forward, 7
]

var sprite_position = {
	Vector3.UP : Vector3( 0.5, 0, 0.5 ),
	Vector3.DOWN : Vector3( 0.5, 1, 0.5 ),
	Vector3.LEFT : Vector3( 1, 0.5, 0.5 ),
	Vector3.RIGHT : Vector3( 0, 0.5, 0.5 ),
	Vector3.FORWARD : Vector3( 0.5, 0.5, 1 ),
	Vector3.BACK : Vector3( 0.5, 0.5, 0 ),
}

const TOP = Vector3( 0, 1, 0 )
const BOTTOM = Vector3( 0, -1, 0 )
const LEFT = Vector3( -1, 0, 0 )
const RIGHT = Vector3( 1, 0, 0 )
const FRONT = Vector3( 0, 0, 1 )
const REAR = Vector3( 0, 0, -1 )

# Faces of a cube.
var direction_vertices = {
	Vector3.UP : [ 2, 3, 7, 6 ],
	Vector3.DOWN : [ 0, 4, 5, 1 ],
	Vector3.LEFT : [ 6, 4, 0, 2 ],
	Vector3.RIGHT : [ 3, 1, 5, 7 ],
	Vector3.FORWARD : [ 7, 5, 4, 6 ],
	Vector3.BACK : [ 2, 0, 1, 3 ]
}

var cross_vertices = [ 2, 0, 5, 7, 6, 4, 1, 3 ]

var uv_a = Vector2( 0, 0 )
var uv_b = Vector2( 0, 1 )
var uv_c = Vector2( 1, 1 )
var uv_d = Vector2( 1, 0 )

var data : ChunkData

#func _ready():
#	var file = FileAccess.open( "res://textures/blocks/minecraft/block_info.txt", FileAccess.READ )
#	var test = file.get_as_text()

# Called when the node enters the scene tree for the first time.
func update():
	for pos in data.blocks:
		draw_block( data.blocks[ pos ], pos )
	instanciate_multimesh()

func instanciate_multimesh():
	for mesh_key in multi_meshes:
		var mm = multi_meshes[ mesh_key ] as MultiMesh
		mm.instance_count = all_mesh_positions[ mesh_key ].size()
		
		for index in mm.instance_count:
			var pos = all_mesh_positions[ mesh_key ][ index ]
			mm.set_instance_transform( index, Transform3D().translated( pos ) )
		
		var m3d = MultiMeshInstance3D.new()
		m3d.multimesh = mm
		m3d.transparency = 1
		add_child( m3d )

func get_texture_path( block : String, direction ) -> String:
	var b = block.replace( ":", "/" )
	if is_liquid( block ): return "res://textures/blocks/%s_still.png" % b
	var base_path = "res://textures/blocks/%s%s.png"
	var path = "";
	# Bottom texture.
	if direction == Vector3.DOWN and FileAccess.file_exists( base_path % [ b, "_bottom" ] ):
		path = base_path % [ b, "_bottom" ]
	# Top or no bottom texture.
	if path == "" and ( direction == Vector3.UP or direction == Vector3.DOWN ) and FileAccess.file_exists( base_path % [ b, "_top" ] ):
		path = base_path % [ b, "_top" ]
	# Sides.
	if path == "" and FileAccess.file_exists( base_path % [ b, "_side" ] ):
		path = base_path % [ b, "_side" ]
	# Normal.
	if path == "":
		path = base_path % [ b, "" ]
	return path

func get_material( block_name : String, direction : Vector3 ) -> ShaderMaterial:
	var texture_path = get_texture_path( block_name, direction )
	# Get the existing material if possible.
	if direction == Vector3.DOWN and materials.has( texture_path ): return materials[ texture_path ]
	elif direction == Vector3.UP and materials.has( texture_path ): return materials[ texture_path ]
	elif direction == Vector3.FORWARD and materials.has( texture_path ): return materials[ texture_path ]
	elif materials.has( texture_path ): return materials[ texture_path ]
	
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter( "tileset_texture", load( texture_path ) )
	return mat

func draw_block( block, pos ) -> void:
	if is_cross( block ):
		draw_block_face( pos, block, Vector3.UP )
	else:
		var is_solid = not is_transparent_block( block )
		if should_draw_face( pos, TOP, is_solid, block ): draw_block_face( pos, block, Vector3.UP )
		if should_draw_face( pos, BOTTOM, is_solid, block ): draw_block_face( pos, block, Vector3.DOWN )
		if should_draw_face( pos, FRONT, is_solid, block ): draw_block_face( pos, block, Vector3.FORWARD )
		if should_draw_face( pos, LEFT, is_solid, block ): draw_block_face( pos, block, Vector3.LEFT )
		if should_draw_face( pos, RIGHT, is_solid, block ): draw_block_face( pos, block, Vector3.RIGHT )
		if should_draw_face( pos, REAR, is_solid, block ): draw_block_face( pos, block, Vector3.BACK )

func is_transparent_block( block : String ):
	if block == "other:air" or block == "none" or is_cross( block ): return true
	return is_liquid( block )

func is_liquid( block : String ):
	var path = "res://textures/blocks/%s_still.png" % block.replace( ":", "/" )
	return FileAccess.file_exists( path )

func is_cross( block : String ):
	return x_blocks.has( block )

func should_draw_face( pos : Vector3, direction : Vector3, is_solid : bool, block : String ) -> bool:
	var next_block = TerrainGenerator.get_block( pos + direction )
	var is_next_solid = not is_transparent_block( next_block )
	# Current block is solid, next is transparent.
	if is_solid and is_next_solid: return false
	# Current block is transparent, next is solid
	if not is_solid and is_next_solid: return false
	# If it's air, dont render.
	if block == "other:air": return false
	# If they are both transparent but not the same type.
	return block != next_block

func draw_block_face( pos : Vector3, block : String, direction : Vector3 ) -> void:
	draw_mesh_face( pos, block, direction )

func is_sprite_sheet( block, direction ):
	var path = get_texture_path( block, direction )
	var texture = load( path ) as Texture2D
	if texture == null: return false
	return texture.get_width() == 16 and texture.get_height() > 32

func draw_mesh_face( pos : Vector3, block : String, direction : Vector3 ):
	var key = block + str( direction )
	if all_mesh_positions.has( key ):
		all_mesh_positions[ key ].append( pos )
		return
	
	var st = SurfaceTool.new()
	st.begin( Mesh.PRIMITIVE_TRIANGLES )
	st.set_smooth_group( -1 )
	
	var vert0 = vertices[ direction_vertices[ direction ][ 0 ] ]
	var vert1 = vertices[ direction_vertices[ direction ][ 1 ] ]
	var vert2 = vertices[ direction_vertices[ direction ][ 2 ] ]
	var vert3 = vertices[ direction_vertices[ direction ][ 3 ] ]
	
	if is_cross( block ):
		st.set_uv( uv_a ); st.add_vertex( vertices[ cross_vertices[ 0 ] ] )
		st.set_uv( uv_b ); st.add_vertex( vertices[ cross_vertices[ 1 ] ] )
		st.set_uv( uv_c ); st.add_vertex( vertices[ cross_vertices[ 2 ] ] )
		st.set_uv( uv_a ); st.add_vertex( vertices[ cross_vertices[ 0 ] ] )
		st.set_uv( uv_c ); st.add_vertex( vertices[ cross_vertices[ 2 ] ] )
		st.set_uv( uv_d ); st.add_vertex( vertices[ cross_vertices[ 3 ] ] )
		st.set_uv( uv_a ); st.add_vertex( vertices[ cross_vertices[ 4 ] ] )
		st.set_uv( uv_b ); st.add_vertex( vertices[ cross_vertices[ 5 ] ] )
		st.set_uv( uv_c ); st.add_vertex( vertices[ cross_vertices[ 6 ] ] )
		st.set_uv( uv_a ); st.add_vertex( vertices[ cross_vertices[ 4 ] ] )
		st.set_uv( uv_c ); st.add_vertex( vertices[ cross_vertices[ 6 ] ] )
		st.set_uv( uv_d ); st.add_vertex( vertices[ cross_vertices[ 7 ] ] )
	else:
		var offset = Vector3( 0, 0, 0 )
		if is_liquid( block ) and direction == Vector3.UP: offset = Vector3( 0, -0.125, 0 )
		st.set_uv( uv_a ); st.add_vertex( vert0 + offset )
		st.set_uv( uv_b ); st.add_vertex( vert1 + offset )
		st.set_uv( uv_c ); st.add_vertex( vert2 + offset )
		st.set_uv( uv_a ); st.add_vertex( vert0 + offset )
		st.set_uv( uv_c ); st.add_vertex( vert2 + offset )
		st.set_uv( uv_d ); st.add_vertex( vert3 + offset )
	st.index()
	
	st.set_material( get_material( block, direction ) )
	st.generate_normals()
	
	var mesh = st.commit()
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	multi_meshes[ key ] = mm
	all_mesh_positions[ key ] = [ pos ]
