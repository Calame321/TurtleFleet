class_name BlockTypes extends Node

const CHUNK_SIZE = 16

# Hold the block indexes.
enum {
	AIR, 
	DIRT, 
	GRASS_HALF, 
	GRASS_FULL,
	GLASS,
	COBBLESTONE,
	ANDESITE,
	DIORITE,
	STONE,
	LOG_MOSSY,
	LOG,
	WOODEN_PLANK,
	SAND,
	SANDSTONE,
	RED_SAND,
	RED_SAND_CRACKED,
	GOLD_ORE,
	COAL_ORE,
	COPPER_ORE,
	VINE_STONE,
	OAK_LEAF
}

# Helper enum to generate the faces of a block.
enum {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	FRONT,
	BACK,
	SOLID,
	GENERATE_FACES,
	SCENE,
	OFFSET
}

# Defines the faces that make a block
# Solid defines if a block is solid or not, so we can see through it.
const types = {
	DIRT : {
		TOP : Vector2( 0, 3 ), BOTTOM: Vector2( 0, 3 ), LEFT : Vector2( 0, 3 ),
		RIGHT : Vector2( 0, 3 ), FRONT: Vector2( 0, 3 ), BACK : Vector2( 0, 3 ),
		SOLID : true
	},
	GRASS_HALF : {
		TOP : Vector2( 2, 3 ), BOTTOM: Vector2( 0, 3 ), LEFT : Vector2( 1, 3 ),
		RIGHT : Vector2( 1, 3 ), FRONT: Vector2( 1, 3 ), BACK : Vector2( 1, 3 ),
		SOLID : true
	},
	GRASS_FULL : {
		TOP : Vector2( 2, 3 ), BOTTOM: Vector2( 2, 3 ), LEFT : Vector2( 2, 3 ),
		RIGHT : Vector2( 2, 3 ), FRONT: Vector2( 2, 3 ), BACK : Vector2( 2, 3 ),
		SOLID : true
	},
	GLASS:{
		TOP : Vector2( 3, 3 ), BOTTOM: Vector2(3,3), LEFT : Vector2(3,3),
		RIGHT : Vector2( 3, 3 ), FRONT: Vector2(3,3), BACK : Vector2(3,3),
		SOLID : false
	},
	COBBLESTONE:{
		TOP : Vector2( 0, 2 ), BOTTOM: Vector2( 0, 2 ), LEFT : Vector2( 0, 2 ),
		RIGHT : Vector2( 0, 2 ), FRONT: Vector2( 0, 2 ), BACK : Vector2( 0, 2 ),
		SOLID : true
	},
	ANDESITE:{
		TOP : Vector2( 1, 2 ), BOTTOM: Vector2( 1, 2 ), LEFT : Vector2( 1, 2 ),
		RIGHT : Vector2( 1, 2 ), FRONT: Vector2( 1, 2 ), BACK : Vector2( 1, 2 ),
		SOLID : true
	},
	DIORITE:{
		TOP : Vector2( 2, 2 ), BOTTOM: Vector2( 2, 2 ), LEFT : Vector2( 2, 2 ),
		RIGHT : Vector2( 2, 2 ), FRONT: Vector2( 2, 2 ), BACK : Vector2( 2, 2 ),
		SOLID : true
	},
	STONE:{
		TOP : Vector2( 3, 2 ), BOTTOM: Vector2( 3, 2 ), LEFT : Vector2( 3, 2 ),
		RIGHT : Vector2( 3, 2 ), FRONT: Vector2( 3, 2 ), BACK : Vector2( 3, 2 ),
		SOLID : true
	},
	LOG_MOSSY:{
		TOP : Vector2( 1, 4 ), BOTTOM: Vector2( 1, 4 ), LEFT : Vector2( 0, 4 ),
		RIGHT : Vector2( 0, 4 ), FRONT: Vector2( 0, 4 ), BACK : Vector2( 0, 4 ),
		SOLID : true
	},
	LOG:{
		TOP : Vector2( 3, 4 ), BOTTOM: Vector2( 3, 4 ), LEFT : Vector2( 2, 4 ),
		RIGHT : Vector2( 2, 4 ), FRONT: Vector2( 2, 4 ), BACK : Vector2( 2, 4 ),
		SOLID : true
	},
	WOODEN_PLANK:{
		TOP : Vector2( 4, 4 ), BOTTOM: Vector2( 4, 4 ), LEFT : Vector2( 4, 4 ),
		RIGHT : Vector2( 4, 4 ), FRONT: Vector2( 4, 4 ), BACK : Vector2( 4, 4 ),
		SOLID : true
	},
	SAND:{
		TOP : Vector2( 0, 5 ), BOTTOM: Vector2( 0, 5 ), LEFT : Vector2( 0, 5 ),
		RIGHT : Vector2( 0, 5 ), FRONT: Vector2( 0, 5 ), BACK : Vector2( 0, 5 ),
		SOLID : true
	},
	SANDSTONE:{
		TOP : Vector2( 1,5 ), BOTTOM: Vector2( 1, 5 ), LEFT : Vector2( 1, 5 ),
		RIGHT : Vector2( 1, 5 ), FRONT: Vector2( 1, 5 ), BACK : Vector2( 1, 5 ),
		SOLID : true
	},
	RED_SAND:{
		TOP : Vector2( 2, 5 ), BOTTOM: Vector2( 2, 5 ), LEFT : Vector2( 2, 5 ),
		RIGHT : Vector2( 2, 5 ), FRONT: Vector2( 2, 5 ), BACK : Vector2( 2, 5 ),
		SOLID : true
	},
	RED_SAND_CRACKED:{
		TOP : Vector2( 3, 5 ), BOTTOM: Vector2( 3, 5 ), LEFT : Vector2( 3, 5 ),
		RIGHT : Vector2( 3, 5 ), FRONT: Vector2( 3, 5 ), BACK : Vector2( 3, 5 ),
		SOLID : true
	},
	GOLD_ORE:{
		TOP : Vector2( 1, 6 ), BOTTOM: Vector2( 1, 6 ), LEFT : Vector2( 1, 6 ),
		RIGHT : Vector2( 1, 6 ), FRONT: Vector2( 1, 6 ), BACK : Vector2( 1, 6 ),
		SOLID : true
	},
	COAL_ORE:{
		TOP : Vector2( 2, 6 ), BOTTOM: Vector2( 2, 6 ), LEFT : Vector2( 2, 6 ),
		RIGHT : Vector2( 2, 6 ), FRONT: Vector2( 2, 6 ), BACK : Vector2( 2, 6 ),
		SOLID : true
	},
	COPPER_ORE:{
		TOP : Vector2( 3, 6 ), BOTTOM: Vector2( 3, 6 ), LEFT : Vector2( 3, 6 ),
		RIGHT : Vector2( 3, 6 ), FRONT: Vector2( 3, 6 ), BACK : Vector2( 3, 6 ),
		SOLID : true
	},
	VINE_STONE:{
		TOP : Vector2( 4, 6 ), BOTTOM: Vector2( 4, 6 ), LEFT : Vector2( 4, 6 ),
		RIGHT : Vector2( 4, 6 ), FRONT: Vector2( 4, 6 ), BACK : Vector2( 4, 6 ),
		SOLID : true
	},
	OAK_LEAF:{
		TOP : Vector2( 0, 7 ), BOTTOM: Vector2( 0, 7 ), LEFT : Vector2( 0, 7 ),
		RIGHT : Vector2( 0, 7 ), FRONT: Vector2( 0, 7 ), BACK : Vector2( 0, 7 ),
		SOLID : false
	},
}

static func get_block_id( name ) -> int:
	if name == "air": return AIR
	elif name == "minecraft:dirt": return DIRT
	elif name == "minecraft:grass_block": return GRASS_HALF
	elif name == "computercraft:wireless_modem_normal": return GLASS
	elif name == "computercraft:wireless_modem_advanced": return GLASS
	elif name == "computercraft:computer_normal": return DIORITE
	elif name == "minecraft:stone": return STONE
	elif name == "minecraft:obsidian": return RED_SAND
	elif name == "minecraft:lime_wool": return LOG_MOSSY
	elif name == "minecraft:crafting_table": return WOODEN_PLANK
	elif name == "minecraft:sand": return SAND
	elif name == "minecraft:water": return COPPER_ORE
	elif name == "computercraft:computer_advanced": return SANDSTONE
	elif name == "minecraft:grass": return GRASS_FULL
	elif name == "minecraft:oak_leaves": return OAK_LEAF
	elif name == "minecraft:oak_log": return LOG
	else: return GOLD_ORE
