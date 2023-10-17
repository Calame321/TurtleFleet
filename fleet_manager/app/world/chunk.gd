extends StaticBody3D

# (texture block size / separation between blocks)
# the textures are 16x16, with a 4px separation for texture bleeding
# texture bleeding is important to avoid inbetween texture seams!!
const tile_size = 16
const separation_between_textures = 4

# Size of your atlas image.
const atlas_width = 96
const atlas_height = 160

var tex_sep = tile_size / separation_between_textures

# 96 / 16 = 6
# 160 / 16 = 10
var TEXTURE_ATLAS_SIZE = Vector2( ( atlas_width / tile_size ) * tex_sep, ( atlas_height / tile_size ) * tex_sep )

var division = tex_sep + 1
var block_script = preload( "res://world/block_types.gd" )

enum {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	FRONT,
	BACK,
	SOLID
}

# Vertices of a cube.
const vertices = [
	Vector3( 0, 0, 0 ),
	Vector3( 1, 0, 0 ),
	Vector3( 0, 1, 0 ),
	Vector3( 1, 1, 0 ),
	Vector3( 0, 0, 1 ),
	Vector3( 1, 0, 1 ),
	Vector3( 0, 1, 1 ),
	Vector3( 1, 1, 1 )
]

# Faces of a cube.
const TOP_VERT = [ 2, 3, 7, 6 ]
const BOTTOM_VERT = [ 0, 4, 5, 1 ]
const LEFT_VERT = [ 6, 4, 0, 2 ]
const RIGHT_VERT = [ 3, 1, 5, 7 ]
const FRONT_VERT = [ 7, 5, 4, 6 ]
const BACK_VERT = [ 2, 0, 1, 3 ]

# With vector 3 positions.
var data : ChunkData

# The surfacetool that will generate the mesh of a chunk.
# It will only generate faces that we need to see.
var st : SurfaceTool = SurfaceTool.new()
var mesh = null
var mesh_instance = null

var material = preload( "res://textures/atlas_texture_material.tres" )

func _ready():
	st.set_smooth_group( -1 )
	material.vertex_color_use_as_albedo = true

# Updates the surface tool everytime a new block
# is added or deleted
# it also remakes it's collision
func update():
	if mesh_instance != null:
		mesh_instance.call_deferred( "queue_free" )
		mesh_instance = null

	st.begin( Mesh.PRIMITIVE_TRIANGLES )

	for pos in data.blocks:
		create_block( pos.x, pos.y, pos.z, data.blocks[ pos ] )

	#st.set_material( material )
	st.generate_normals()
	st.generate_tangents()
	
	# Generate the mesh and add it to the world.
	mesh = Mesh.new()
	mesh = st.commit()
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.set_surface_override_material( 0, material )
	add_child( mesh_instance )

# This functions checks for a transparent block/object in the x,y,z coordinate
# If it is transparent, we render the block through it
# If it is solid, then we hide the mesh /face.
# That way, only the faces that are shown will be rendered.
func check_transparent( x, y, z ):
	return true
	var chunk_coords = Vector2( floor( x / BlockTypes.CHUNK_SIZE ), floor( z / BlockTypes.CHUNK_SIZE ) )
	var chunk_key = [ chunk_coords.x, chunk_coords.y ]
	
	if !get_parent().get_parent().chunks.has( chunk_key ):
		return true
	
	var chunk_to_check = get_parent().get_parent().chunks[ chunk_key ]
	
	if chunk_to_check[ "blocks" ].has( [ x, y, z ] ) == true:
		var idx = [ x, y, z ]
		var type = chunk_to_check[ "blocks" ][ idx ][ "type" ]
		return not BlockTypes.types[ type ][ SOLID ]
	else:
		return true

# This creates the faces of a block, based on its type.
# It will also check if it actually needs to create a face, based on if
# it's is hidden by a solid block or not.
func create_block( x, y, z, block_type ):
	var block = block_type
	if block == 0: # AIR
		return
	
	var offset = Vector3i( x, y, z )
	
	if check_transparent( x, y + 1, z ): create_face( TOP_VERT, offset, TOP, block )
	if check_transparent( x, y - 1, z ): create_face( BOTTOM_VERT, offset, BOTTOM, block )
	if check_transparent( x - 1, y, z ): create_face( LEFT_VERT, offset, LEFT, block )
	if check_transparent( x + 1, y ,z ): create_face( RIGHT_VERT, offset, RIGHT, block )
	if check_transparent( x, y, z + 1 ): create_face( FRONT_VERT, offset, FRONT, block )
	if check_transparent( x, y, z - 1 ): create_face( BACK_VERT, offset, BACK, block )

# Creates a face and set it's texture.
# It takes into account the atlas texture with the block textures.
func create_face( i, offset, direction, block ):
	var block_info = BlockTypes.types[ block ]
	var a = vertices[ i[ 0 ] ] + offset
	var b = vertices[ i[ 1 ] ] + offset
	var c = vertices[ i[ 2 ] ] + offset
	var d = vertices[ i[ 3 ] ] + offset
	
	var uv_offset = ( block_info[ direction ] * division ) / TEXTURE_ATLAS_SIZE
	var height = tex_sep / TEXTURE_ATLAS_SIZE.y 
	var width = tex_sep / TEXTURE_ATLAS_SIZE.x
	
	var uv_a = uv_offset + Vector2( 0, 0 )
	var uv_b = uv_offset + Vector2( 0, height )
	var uv_c = uv_offset + Vector2( width, height )
	var uv_d = uv_offset + Vector2( width, 0 )
	
	st.add_triangle_fan( [ a, b, c ], [ uv_a, uv_b, uv_c ] )
	st.add_triangle_fan( [ a, c, d ], [ uv_a, uv_c, uv_d ] )
