local Page = require( "turtlefleet.ui.components.page" )
local Panel = require( "turtlefleet.ui.components.panel" )
local Selector = require( "turtlefleet.ui.components.selector" )
local Label = require( "turtlefleet.ui.components.label" )
local BackButton = require( "turtlefleet.ui.components.back_button" )
local Title = require( "turtlefleet.ui.components.title" )

local BranchMiningPage = Page:new()
local selector = Selector:new():set_focus( true )
local lbl_length = Label:new( "15", 15, 3 )
local lbl_branch = Label:new( "15", 15, 4 )

local farm_length = 15
local farm_branch = 15

local function start_farm( side )
  turtle.start_branch_mining( side, farm_length, farm_branch )
end

local function add_length()
  farm_length = farm_length + 1
  lbl_length:set_text( tostring( farm_length ) )
end

local function sub_length()
  farm_length = math.max( 1, farm_length - 1 )
  lbl_length:set_text( tostring( farm_length ) )
end

local function add_branch()
  farm_branch = farm_branch + 1
  lbl_branch:set_text( tostring( farm_branch ) )
end

local function sub_branch()
  farm_branch = math.max( 1, farm_branch - 1 )
  lbl_branch:set_text( tostring( farm_branch ) )
end

selector
  :add_component( Label:new( " Left", 3, 4 ):set_func( function() start_farm( "left" ) end, { keys.l } ) )
  :add_component( Label:new( " Right", 3, 5 ):set_func( function() start_farm( "right" ) end, { keys.r } ) )
  :add_component( Label:new( "+", 14, 9 ):set_func( add_length ) )
  :add_component( Label:new( "-", 21, 9 ):set_func( sub_length ) )
  :add_component( Label:new( "+", 14, 10 ):set_func( add_branch ) )
  :add_component( Label:new( "-", 21, 10 ):set_func( sub_branch ) )
BranchMiningPage
  :add_component( Title:new( "Branch Mining", string.char( 127 ), colors.gray ) )
  :add_component( BackButton:new( "miner/miner_page" ) )
  :add_component( Label:new( "Start:", 3, 3 ) )
  :add_component( selector )
  :add_component( Panel:new( 3, 7, 20, 5 ):set_title( "Settings:" ):border( true ):set_color( colors.lightBlue )
    :add_component( Label:new( "Length:", 2, 3 ) )
    :add_component( Label:new( "branches:", 2, 4 ) )
    :add_component( lbl_length )
    :add_component( lbl_branch )
  )
return BranchMiningPage
--[[
  print( "- Branch Mining -" )
  print( "For this one, the turtle need to be facing a chest. It will mine the number of branches of specified of the specified length." )

  print( "The turtle should turn:" )
  print( "1 = left (default)" )
  print( "2 = right")
  local branch_side = "left"

  if input == "2" then
    branch_side = "left"
  end

  miner.start_branch_mining( branch_side, branch_quantity, branch_quantity )
]]