local ui = require( "basalt" )
 
local w, h = term.getSize()

local main = ui.createFrame():addLayout("turtlefleet/ui/main.xml"):show()
local pages = main:getDeepObject( "pages" )

local test = pages:addLayout("turtlefleet/ui/tree_farm.xml"):show()

local tree_farm_frame = main:getDeepObject( "tf_frame" )
local lbl_event = main:getDeepObject( "lbl_event" )
local lbl_time = main:getDeepObject( "lbl_time" )

local lbl_up = main:getDeepObject( "lbl_up" ):hide()
local lbl_down = main:getDeepObject( "lbl_down" )

main
  :onEvent(
    function( self, event, value ) 
          
      if event ~= "timer" then
        lbl_event:setText( event .. ": " .. value )

        if event == "key" then
          -- Down: Scroll page
          if value == 264 then
            local offx, offy = pages:getOffset()
            local frame_h = pages:getHeight()
            local new_offy = math.abs(offy) + 1
            pages:setOffset( offx, math.min( pages:getHeight(), new_offy ) )
            lbl_up:show()
            if frame_h <= new_offy then lbl_down:hide() end

          -- Up: Scroll page
          elseif value == 265 then
            local offx, offy = pages:getOffset()
            local new_offy = -offy - 1
            pages:setOffset( offx, math.max( 0, new_offy ) )
            lbl_down:show()
            if new_offy == 0 then lbl_up:hide() end
            
          -- Alt: Focus main menu bar
          elseif value == 342 then
            --menuBar:setFocus()
          end

        elseif event == "char" then
          -- Menu handle the char if focused.
          --menuBar:keyHandler( menuBar, event, value )
        end
      end
    end
  )

local timer = main
  :addTimer( "every_second_timer" )
  :onCall(
    function()
      -- Set the time
      lbl_time
        :setText( textutils.formatTime( os.time() ) )
        :show()
    end
  )
  :setTime( 1, -1 )
  :start()

ui.autoUpdate()