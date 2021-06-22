os.loadAPI( "disk/turtleFleet/position" )

local _pos = Position:new()
local _job

function loadSetting()
    _pos:init( settings.get( "pos" ) )
    _job = settings.get( "job" )
end

function getOrientation()
    while peripheral.getType( "left" ) ~= "modem" do
        turtle.turnLeft()
    end

    settings.set( "pos", { face = _pos.face, coords = _pos.coords } )
end

function getJob()
    rednet.open( "left" )
    local r = rednet.lookup( "tf", "main" )
    rednet.send( r, "getJob" )
    local id, job = rednet.receive()
    _job = job
    settings.set( "job", _job )
end

if settings.get( "setupDone" ) == nil then
    getOrientation()
    getJob()
    settings.set( "setupDone", true )
    settings.save( ".settings" )
else
    loadSetting()
end