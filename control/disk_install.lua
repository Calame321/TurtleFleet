function Validate()
    if not IsColor() then
        print( "! You must use an advanced computer." )
        return false
    end
    
    if not HasDisk() then
        print( "! You must have a disk drive with a disk connected on the right." )
        return false
    end

    return true
end

function IsColor()
    if not term.isColor then
        return false
    elseif term.isColor() then
        return true
    else
        return false
    end
end

function HasDisk()
    if peripheral.getType( "right" ) == "drive" then
        if disk.isPresent( "right" ) and disk.hasData( "right" ) then
            disk.setLabel( "right", "TurtleFleet" )
            return true
        end
    end

    return false
end

-- Start here --
if not Validate() then
    return
end

fs.delete( "disk/TurtleFleet" )
fs.delete( "disk/startup" )
shell.run( "pastebin get Qwnd0Bqn disk/turtleFleet/turtleFiles/startup" )
shell.run( "pastebin get wST39n3Y disk/turtleFleet/ui/topMenuBar" )
shell.run( "pastebin get mHPEuRWe disk/turtleFleet/ui/statusBar" )
shell.run( "pastebin get 1VXZWMr5 disk/turtleFleet/ui/iconGrid" )
shell.run( "pastebin get hzH44zMc disk/turtleFleet/ui/popup" )
shell.run( "pastebin get cYcfgb1B disk/turtleFleet/img/iconMissing" )
shell.run( "pastebin get 7j5zcgEV disk/turtleFleet/img/inventory" )
shell.run( "pastebin get bkGGYx1A disk/turtleFleet/img/tree" )
shell.run( "pastebin get JtpUD52L disk/turtleFleet/img/mine" )
shell.run( "pastebin get XhNLLjtY disk/turtleFleet/computerController" )
shell.run( "pastebin get scxYfGAY disk/turtleFleet/mainMenu" )
shell.run( "pastebin get Y7N16yV5 disk/turtleFleet/worldMap" )
shell.run( "pastebin get g0QsFHbg disk/turtleFleet/position" )
shell.run( "pastebin get ifZFvTAN disk/turtleFleet/network" )
shell.run( "pastebin get pt8MgyKt disk/turtleFleet/utils" )
shell.run( "pastebin get aKUyjvrs disk/startup" )
shell.run( "disk/startup" )