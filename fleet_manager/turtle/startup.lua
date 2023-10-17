-------------------------
-- All required files. --
-------------------------

-- Models.
Turtle = require( "models.turtle" )
Node3D = require( "models.node" )
Queue = require( "models.queue" )
Chunk = require( "models.chunk" )
Log = require( "models.log" )

-- Tasks.
Scouting = require( "tasks.scouting" )
Building = require( "tasks.building" )
ReturnHome = require( "tasks.return_home" )

-- Managers.
TSettingsManager = require( "managers.t_settings_manager" )
TNetworkManager = require( "managers.t_network_manager" )
TEventManager = require( "managers.t_event_manager" )
TTaskManager = require( "managers.t_task_manager" )
ChunkManager = require( "managers.chunk_manager" )
TLogManager = require( "managers.t_log_manager" )
TUiManager = require( "managers.t_ui_manager" )

-- Other.
turtle = require( "other.advanced_turtle" )
TPathfind = require( "other.t_pathfind" )
Pretty = require( "cc.pretty" )
Utils = require( "other.utils" )


-------------------
-- Initial Setup --
-------------------

turtle.data = Turtle.new( turtle )
term.clear()
term.setCursorPos( 1, 1 )
TSettingsManager.init()
turtle.data:set_missing()
TNetworkManager.start()

-- Get the position using the GPS.
-- If there is no gps:
--   DONT use coordinates movements.
--   reset position to 0 and facing to north.
--   can use local function of turtle-fleet. (flatten, dig out, etc.)

-- If valid gps position AND no inventory mismatch AND position_acuracy is good
--   dont need to check orientation
--   BUT, should confirm it when we move!
-- position is perfect
-- a variable for facing_acuracy?


-- Stay in place and try to connect evert 15 - 30 sec?


-------------------
-- Main function --
-------------------
local function main()
  while true do
    TTaskManager.execute_task()
    sleep( 1 )
  end
end

-- Start a thread for the main loop and another one to check for rednet messages.
parallel.waitForAll( main, TEventManager.check_events, TUiManager.display )
print( "Everything done!" )
