-------------------------
-- All required files. --
-------------------------

-- Models.
Node2D = require( "models.node2d" )
Turtle = require( "models.turtle" )
Queue = require( "models.queue" )
Chunk = require( "models.chunk" )
Task = require( "models.task" )
Log = require( "models.log" )
require( "models.crafting_option" )
require( "models.crafting_node" )
require( "models.recipe" )

-- Repositories.
TaskRepository = require( "repositories.task_repository")

-- Managers.
CCraftingManager = require( "managers.c_crafting_manager")
CSettingsManager = require( "managers.c_settings_manager")
CNetworkManager = require( "managers.c_network_manager" )
StorageManager = require( "managers.storage_manager")
CEventManager = require( "managers.c_event_manager")
FleetManager = require( "managers.fleet_manager" )
WorldManager = require( "managers.world_manager" )
CTaskManager = require( "managers.task_manager" )
CLogManager = require( "managers.c_log_manager" )
CUiManager = require( "managers.ui_manager" )

-- Program.
Program = require( "main" )

-- Other.
table = require( "other.table_extension" )
Pathfind = require( "other.pathfind" )
Pretty = require( "cc.pretty" )

term.clear()
CSettingsManager.init()
WorldManager.load_all_chunk()
FleetManager.load_all()

parallel.waitForAll( CNetworkManager.start, FleetManager.ping_turtles, CTaskManager.loop, Program.main, CUiManager.display )
print( "Everything done!" )