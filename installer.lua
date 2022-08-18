---------------------------
-- TurtleFleet Installer --
---------------------------
local git_path = "https://raw.githubusercontent.com/Calame321/TurtleFleet/main/"
local fleet_folder = "turtlefleet/"
local all_files = {
  "computer/computer_startup.lua",
  "control/manual_command.lua",
  "control/network.lua",
  "jobs/builder.lua",
  "jobs/cooker.lua",
  "jobs/job.lua",
  "jobs/miner.lua",
  "stations/mine.lua",
  "stations/station.lua",
  "stations/treefarm.lua",
  "turtle/advanced_turtle.lua",
  "turtle/pathfind.lua",
  "turtle/turtle_startup.lua",
  "utils/update.lua",
  "img/mine",
  "img/tree",
  "img/inventory",
  "img/icon_missing",
}

-- Center the text based on the total length
function print_centered( text, from, to, line, back_color, fore_color )
  back_color = back_color or colors.white
  fore_color = fore_color or colors.blue
	local total_length = to - from
  local half_text_length = #text / 2
  local offset = math.ceil( ( ( total_length / 2 ) + from ) - half_text_length )
  term.setCursorPos( offset, line )
  term.setBackgroundColor( back_color )
  term.setTextColor( fore_color )
  term.write( text )
end

term.clear()
local lastBgColor = term.getBackgroundColor()
local width, height = term.getSize()
local mid_x = math.ceil( width / 2 )
local mid_y = math.ceil( height / 2 )
local panel_x, panel_x2, panel_y, panel_y2 = mid_x - 16, mid_x + 16, mid_y - 3, mid_y + 3

local panel_color1, panel_color2, panel_color3 = colors.blue, colors.lightBlue, colors.cyan

-- Draw the panel.
paintutils.drawFilledBox( panel_x, panel_y, panel_x2, panel_y2, colors.white )
-- Add a border.
paintutils.drawBox( panel_x - 1, panel_y - 1, panel_x2 + 1, panel_y2 + 1, panel_color1 )
paintutils.drawPixel( panel_x - 1, panel_y2 + 1, panel_color3 )
paintutils.drawPixel( panel_x2 + 1, panel_y2 + 1, panel_color3 )
-- Add box for the headder.
paintutils.drawFilledBox( panel_x - 1, panel_y - 1, panel_x2 + 1, panel_y + 1, panel_color2 )
paintutils.drawLine( panel_x - 1, panel_y - 1, panel_x - 1, panel_y + 1, panel_color3 )
paintutils.drawLine( panel_x2 + 1, panel_y - 1, panel_x2 + 1, panel_y + 1, panel_color3 )
-- Add the title.
print_centered( "TurtleFleet Installer", panel_x, panel_x2, panel_y, panel_color2, colors.black )
-- Add the text.
print_centered( "Do you want to install", panel_x, panel_x2, panel_y + 3, nil, colors.green )
print_centered( "TurtleFleet?", panel_x, panel_x2, panel_y + 4, nil, colors.green )

-- Button Yes
local yes_x = panel_x2 - 11
local yes_x2 = panel_x2 - 1
local btn_y = panel_y2
local btn_y2 = panel_y2 + 2
paintutils.drawFilledBox( yes_x, btn_y, yes_x2, btn_y2, colors.green )
print_centered( "Indeed!", yes_x, yes_x2, btn_y + 1, colors.green, colors.white )
print_centered( "\175" .. "      ", yes_x, yes_x2, btn_y2, colors.green, colors.white )

-- Button No
local no_x = panel_x + 1
local no_x2 = panel_x + 10
paintutils.drawFilledBox( no_x, btn_y, no_x2, btn_y2, colors.orange )
print_centered( "Nah...", no_x, no_x2, btn_y + 1, colors.orange, colors.red )
print_centered( "\175" .. "     ", no_x, no_x2, btn_y2, colors.orange, colors.red )

term.setBackgroundColor( lastBgColor )
local was_installed = false

while ( true ) do
  local event, p1, p2, p3, p4 = os.pullEvent()

  if ( event == "key" ) then
    if keys.getName( p1 ) == 'i' then
      was_installed = true
      break
    end

    if keys.getName( p1 ) == 'n' then
      break
    end
  end

  if ( event == "mouse_click" ) then
    local x = p2
    local y = p3

    local yes_was_clicked = x >= yes_x and x <= yes_x2 and y >= btn_y and y <= btn_y2

    if ( yes_was_clicked ) then
      --shell.run( "pastebin run ESs1mg7P" )
      was_installed = true
      break
    end

    local no_was_clicked = x >= no_x and x <= no_x2 and y >= btn_y and y <= btn_y2

    if no_was_clicked then
      break
    end
  end
end

term.setCursorPos( 1, 1 )
term.clear()
if was_installed then
  print_centered( "INSTALLED!", 1, 16, 1, colors.lime, colors.green )
else
  print_centered( "CANCELLED!", 1, 16, 1, colors.red, colors.pink )
end