------------
-- Visual --
------------
visual = {}

local UL = "\134"
local U = "\131"
local UR = "\137"
local LR = "\149"

local width, height = term.getSize()

function visual:draw_table()
    term.clear()
    term.setCursorPos( 1, 1 )

    for x = 1, width do
        for y = 1, height do
            term.setCursorPos( x, y )

            if x == 1 or x == height then
                print( LR )
            elseif y == 1 or y == height
                print( U )
            end
        end
    end
end

return visual