shader_type spatial;
render_mode cull_disabled, depth_draw_always, depth_prepass_alpha;

uniform vec3 model_dimensions = vec3( 1.0, 1.0, 1.0 );

uniform vec2 tile_size = vec2( 16.0, 16.0 );
uniform float texture_scale : hint_range( 0.1, 10.0 ) = 1.0;
uniform sampler2D tileset_texture: source_color, filter_nearest, repeat_enable;

varying vec3 instance_pos;
varying mat4 model_matrix;

void vertex() {
	// Position of Instance, supports MultiMeshInstances in the use of GridMaps
    instance_pos = MODEL_MATRIX[ 3 ].xyz;
    model_matrix = MODEL_MATRIX;
}

vec4 triplanar_texture( vec3 world_position, vec3 normal ) {
	vec2 tileset_dimensions = vec2( textureSize( tileset_texture, 0 ) ) / tile_size;
	vec2 tile_uv_scale = tile_size / vec2( textureSize( tileset_texture, 0 ) );
	
	float animation_speed = tileset_dimensions.y / 2.0;
    float frame = mod( TIME * animation_speed, tileset_dimensions.y );
    vec2 tile_offset = vec2( mod( round( frame ), tileset_dimensions.x ), floor( frame / tileset_dimensions.x ) ) * tile_uv_scale;
	
	vec2 zy = -world_position.zy / model_dimensions.zy;
	vec2 zx = world_position.zx / model_dimensions.zx;
	vec2 xy = -world_position.xy / model_dimensions.xy;
	float mz = ( model_dimensions.z - 1.0 ) / ( 2.0 * model_dimensions.z );
	float mx = ( model_dimensions.x - 1.0 ) / ( 2.0 * model_dimensions.x );
	float my = ( model_dimensions.y - 1.0 ) / ( 2.0 * model_dimensions.y );
	
	vec2 uv1 = ( zy - vec2( -mz ) ) * texture_scale;
	vec2 uv2 = ( zy - vec2( -mz ) ) * texture_scale;
	vec2 uv3 = ( zx + vec2( mz, -mx ) ) * texture_scale;
	vec2 uv4 = ( zx + vec2( mz, -mx ) ) * texture_scale;
	vec2 uv5 = ( xy + vec2( mx, my ) ) * texture_scale;
	vec2 uv6 = ( xy + vec2( mx, my ) ) * texture_scale;
	
	vec4 colors[ 6 ];
	colors[ 0 ] = texture( tileset_texture, fract( uv1 ) * tile_uv_scale + tile_offset );
	colors[ 1 ] = texture( tileset_texture, fract( uv2 ) * tile_uv_scale + tile_offset );
	colors[ 2 ] = texture( tileset_texture, fract( uv3 ) * tile_uv_scale + tile_offset );
	colors[ 3 ] = texture( tileset_texture, fract( uv4 ) * tile_uv_scale + tile_offset );
	colors[ 4 ] = texture( tileset_texture, fract( uv5 ) * tile_uv_scale + tile_offset );
	colors[ 5 ] = texture( tileset_texture, fract( uv6 ) * tile_uv_scale + tile_offset );
	
	vec3 weights = abs( normal );
	vec4 color = weights.x * ( normal.x > 0.0 ? colors[ 0 ] : colors[ 1 ] ) +
				 weights.y * ( normal.y > 0.0 ? colors[ 2 ] : colors[ 3 ] ) +
				 weights.z * ( normal.z > 0.0 ? colors[ 4 ] : colors[ 5 ] );
	return color;
}

void fragment() {
	vec3 world_position = ( INV_VIEW_MATRIX * vec4( VERTEX, 1.0 ) ).xyz - instance_pos;
	vec3 world_normal = ( INV_VIEW_MATRIX * vec4( NORMAL, 0.0 ) ).xyz;
	vec4 albedo = triplanar_texture( inverse( mat3( model_matrix ) ) * world_position, inverse( mat3( model_matrix ) ) * world_normal );
	if ( albedo.a < 0.1 ) { discard; }
	ALBEDO = albedo.rgb;
	ALPHA = albedo.a;
}