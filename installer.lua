---------------------------
-- TurtleFleet Installer --
---------------------------
local width, height = term.getSize()
local mid_x = math.ceil( width / 2 )
local mid_y = math.ceil( height / 2 )
local panel_x, panel_x2, panel_y, panel_y2 = mid_x - 16, mid_x + 16, mid_y - 3, mid_y + 3
local yes_x = panel_x2 - 9
local yes_x2 = panel_x2 - 1
local btn_y = panel_y2
local btn_y2 = panel_y2 + 2
local no_x = panel_x + 1
local no_x2 = panel_x + 8

local was_installed = false
local theme = {}

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
  back_color = back_color or theme.text_bg
  fore_color = fore_color or theme.text_fg
	local total_length = to - from
  local half_text_length = #text / 2
  local offset = math.ceil( ( ( total_length / 2 ) + from ) - half_text_length )
  term.setCursorPos( offset, line )
  term.setBackgroundColor( back_color )
  term.setTextColor( fore_color )
  term.write( text )
end

-- Display a promt for the installation.
function show_prompt()
  if term.isColor() then
    theme = {
      bg = colors.white,
      text_bg = colors.white,
      text_fg = colors.blue,
      title_bg = colors.lightBlue,
      title_fg = colors.black,
      window_border = colors.blue,
      window_corners = colors.cyan,
      window_text_fg = colors.green,
      here_btn_bg = colors.green,
      here_btn_fg = colors.orange,
      disk_btn_bg = colors.brown,
      disk_btn_fg = colors.yellow,
      text_error = colors.red
    }
  else
    theme = {
      bg = colors.white,
      text_bg = colors.white,
      text_fg = colors.blue,
      title_gb = colors.lightBlue,
      title_fg = colors.black,
      window_border = colors.blue,
      window_corners = colors.cyan,
      window_text_fg = colors.green,
      here_btn_bg = colors.green,
      here_btn_fg = colors.white,
      disk_btn_bg = colors.lightBlue,
      disk_btn_fg = colors.blue,
      text_error = colors.red
    }
  end

  term.clear()
  local lastBgColor = term.getBackgroundColor()

  -- Draw the panel.
  paintutils.drawFilledBox( panel_x, panel_y, panel_x2, panel_y2, theme.bg )
  -- Add a border.
  paintutils.drawBox( panel_x - 1, panel_y - 1, panel_x2 + 1, panel_y2 + 1, theme.window_border )
  paintutils.drawPixel( panel_x - 1, panel_y2 + 1, theme.window_corners )
  paintutils.drawPixel( panel_x2 + 1, panel_y2 + 1, theme.window_corners )
  -- Add box for the headder.
  paintutils.drawFilledBox( panel_x - 1, panel_y - 1, panel_x2 + 1, panel_y + 1, theme.title_bg )
  paintutils.drawLine( panel_x - 1, panel_y - 1, panel_x - 1, panel_y + 1, theme.window_corners )
  paintutils.drawLine( panel_x2 + 1, panel_y - 1, panel_x2 + 1, panel_y + 1, theme.window_corners )
  -- Add the title.
  print_centered( "TurtleFleet Installer", panel_x, panel_x2, panel_y, theme.title_bg, theme.title_fg )
  -- Add the text.
  print_centered( "Where to install?", panel_x, panel_x2, panel_y + 3, nil, theme.window_text_fg )

  -- Button Here
  paintutils.drawFilledBox( yes_x, btn_y, yes_x2, btn_y2, theme.here_btn_bg )
  print_centered( "Here!", yes_x + 1, yes_x2, btn_y + 1, theme.here_btn_bg, theme.here_btn_fg )
  print_centered( "\175" .. "    ", yes_x, yes_x2, btn_y2, theme.here_btn_bg, theme.here_btn_fg )

  -- Button Disk
  paintutils.drawFilledBox( no_x, btn_y, no_x2, btn_y2, theme.disk_btn_bg )
  print_centered( "Disk.", no_x + 1, no_x2, btn_y + 1, theme.disk_btn_bg, theme.disk_btn_fg )
  print_centered( "\175" .. "   ", no_x, no_x2, btn_y2, theme.disk_btn_bg, theme.disk_btn_fg )

  term.setBackgroundColor( lastBgColor )
end

-- Show installing message.
function show_installing()
  local _x = panel_x + 1
  local _x2 = panel_x2 - 1
  local _y = panel_y2
  local _y2 = panel_y2 + 2
  paintutils.drawFilledBox( _x, _y, _x2, _y2, theme.disk_btn_bg )
  print_centered( "Installing...", _x + 1, _x2, _y + 1, theme.disk_btn_bg, theme.disk_btn_fg )
end

-- Install the software on the current turtle or computer.
function install_here()
  fs.delete( "turtlefleet" )
  fs.delete( "startup" )

  local to_install = {}
  for i = 1, #all_files do
    to_install[ git_path .. all_files[ i ] ] = fleet_folder .. all_files[ i ]
  end

  to_install[ git_path .. "startup.lua" ] = "startup.lua"

  install_files( to_install )
  was_installed = true
end

-- Install the files on a disk for easy mass install.
function install_disk()
  fs.delete( "/disk/main_startup" )
  fs.delete( "/disk/turtlefleet" )
  fs.delete( "/disk/startup" )

  local to_install = {}
  for i = 1, #all_files do
    to_install[ git_path .. all_files[ i ] ] =  "/disk/" ..fleet_folder .. all_files[ i ]
  end

  to_install[ git_path .. "startup.lua" ] = "/disk/main_startup.lua"
  to_install[ git_path .. "disk_startup.lua" ] = "/disk/startup.lua"

  install_files( to_install )
  was_installed = true
end

-- Install the file from the dictionary.
function install_files( files_to_install )
  local i = 1

  for git_file, local_file in pairs( files_to_install ) do
    local f = fs.open( local_file, "w" )
    local w, m = http.get( git_file )

    if w then
      f.write( w.readAll() )
      f.flush()
      f.close()

      local file_count = 0
      for _ in pairs( files_to_install ) do file_count = file_count + 1 end
      display_progress( i, file_count, local_file )

      i = i + 1
    else
      display_error( "Can't load '" .. local_file .. "' : " .. m )
    end
  end
end

-- Display a progress bar.
function display_progress( current, max, current_file )
  local bar_width = 20
  local progress = math.floor( current * bar_width / max )

  local bar = ""
  local bar_fg = ""
  local bar_bg = ""
  for i = 1, bar_width do
    if i <= progress then
      bar = bar .. ""
      bar_fg = bar_fg .. "0"
      bar_bg = bar_bg .. "b"
    else
      bar = bar .. ""
      bar_fg = bar_fg .. "3"
      bar_bg = bar_bg .. "0"
    end
  end

  local total_length = panel_x2 - panel_x
  local position_x = total_length / 2 - #bar / 2
  term.setCursorPos( panel_x + position_x, panel_y + 4 )
  term.setBackgroundColor( theme.bg )
  term.setTextColor( theme.text_fg )

  if #current_file > 20 then
    write( "..." .. string.sub( current_file, -17 ) )
  else
    write( current_file .. ( string.rep( " ", 20 - #current_file ) ) )
  end

  term.setCursorPos( panel_x + position_x, panel_y + 3 )
  term.blit( bar, bar_fg, bar_bg )
end

-- Display an error if a file is not found.
function display_error( message )
  term.setCursorPos( 1, height )
  term.setTextColor( theme.text_error )
  term.write( message )
  term.setTextColor( theme.text_fg )
end

-- Show the prompt and listen to events.
show_prompt()

while ( true ) do
  local event, p1, p2, p3, p4 = os.pullEvent()

  -- If key pressed.
  if ( event == "key" ) then
    if keys.getName( p1 ) == 'h' then
      show_installing()
      install_here()
      break
    end

    if keys.getName( p1 ) == 'd' then
      show_installing()
      install_disk()
      break
    end
  end

  -- If clicked.
  if ( event == "mouse_click" ) then
    local x = p2
    local y = p3

    local here_was_clicked = x >= yes_x and x <= yes_x2 and y >= btn_y and y <= btn_y2
    if ( here_was_clicked ) then
      show_installing()
      install_here()
      break
    end

    local disk_was_clicked = x >= no_x and x <= no_x2 and y >= btn_y and y <= btn_y2
    if disk_was_clicked then
      show_installing()
      install_disk()
      break
    end
  end
end

-- Show the end message.
function show_end()
  local txt = "Installation Completed!"
  local total_length = panel_x2 - panel_x
  local position_x = total_length / 2 - #txt / 2
  term.setCursorPos( panel_x + position_x + 1, panel_y + 4 )
  write( txt )

  local _x = panel_x + 1
  local _x2 = panel_x2 - 1
  local _y = panel_y2
  local _y2 = panel_y2 + 2
  paintutils.drawFilledBox( _x, _y, _x2, _y2, theme.window_text_fg )
  print_centered( "Press Enter to reboot.", _x + 1, _x2, _y + 1, theme.window_text_fg, theme.text_bg )
end

show_end()
read()
os.reboot()