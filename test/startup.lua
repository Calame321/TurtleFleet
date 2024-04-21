-- Change pink for a darker cyan.
term.setPaletteColor( colors.pink, 0x33768C )

table = require( "turtlefleet.utils.table_extension" )

TSettingsManager = require( "turtlefleet.managers.t_settings_manager" )
turtle = require( "turtlefleet.turtle.advanced_turtle" )

TSettingsManager.init()

term.width, term.height = term.getSize()

local events = {}
local blink_state = true
local current_page

local function load_page( name )
  current_page = require( "turtlefleet.ui.pages." .. name )
end

load_page( "main_menu_page" )

current_page:draw()

local function change_page( name )
  load_page( name )
  current_page:draw()
end

local function get_events()
  while true do
    local event = { os.pullEvent() }
    if event[ 0 ] ~= "timer" then
      table.insert( events, event )
    end
  end
end

local function process_events()
  local count = 1
  while true do
    if events[ 1 ] then
      local event = events[ 1 ]
      if event[ 1 ] == "key" then
        current_page:on_key( event[ 2 ] )
      elseif event[ 1 ] == "char" then
        current_page:on_char( event[ 2 ] )
      elseif event[ 1 ] == "mouse_click" then
        current_page:on_click( event[ 2 ], event[ 3 ], event[ 4 ] )
      elseif event[ 1 ] == "page_selected" then
        change_page( event[ 2 ] )
      end
      table.remove( events, 1 )
    end
    -- Prevent error "too long without yielding"
    count = count + 1
    if count == 1000 then
      sleep( 0 )
      count = 1
    end
    current_page:resume_coroutines()
  end
end

local function blink()
  while true do
    current_page:blink( blink_state )
    blink_state = not blink_state
    sleep( 0.8 )
  end
end

parallel.waitForAll( get_events, process_events, blink )