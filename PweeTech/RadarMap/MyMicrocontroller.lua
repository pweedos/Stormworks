--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "5x3")
    simulator:setProperty("Max Radar Distance", 50000)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(3, simulator:getIsToggled(1))--On
        simulator:setInputBool(4, simulator:getIsClicked(2))--Target Detected
        simulator:setInputNumber(7, simulator:getSlider(1))-- Radar Rotation
        simulator:setInputNumber(8, simulator:getSlider(2)*50000)--Target Distance
        simulator:setInputNumber(10, simulator:getSlider(4)*0.05)--Target Elevation
        simulator:setInputNumber(11, simulator:getSlider(5)*500)--GPSX
        simulator:setInputNumber(12, simulator:getSlider(6)*500)--GPSY
        simulator:setInputNumber(14, simulator:getSlider(7)*1)--Compass
        simulator:setInputNumber(15, simulator:getSlider(8)*50)--Zoom
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

gN = input.getNumber
gB = input.getBool
sN = output.setNumber
sB = output.setBool
pN = property.getNumber
pB = property.getBool
pT = property.getText

tick = 0
Tgts = {}
function onTick()
    RadarRot = gN(7)
    TgtDist = gN(8)
    TgtAz = gN(9)
    TgtEle = gN(10)
    GPSX = gN(11)
    GPSY = gN(12)
    Altitude = gN(13)
    Compass = gN(14)*-1
    Zoom = gN(15)
    MaxDist = pN("Max Radar Distance")
    AzDetec = pN("Azimuth Detection")
    
    Touch1 = gB(1)
    TgtFound = gB(4)

    tick = tick + 1
    while RadarRot >= 1 do
        RadarRot = RadarRot - 1
    end
    if TgtFound and TgtAz <= AzDetec and TgtAz >= (AzDetec*-1) and TgtDist >= 100 then
        tgt = {Rot = RadarRot, Dist = TgtDist, Az = TgtAz, Elev = TgtEle, Time = tick}
        table.insert(Tgts, tgt)
    end
    for i, tgt in ipairs(Tgts) do
        if tick - tgt.Time >= 500 or tick - tgt.Time <= -500 then
            table.remove(Tgts, i)
        end
    end
end

function drawArc(x, y, R, SAng, EAng, Fill, Step)
	SAng = SAng -180 or 0
	EAng = EAng -180 or 360
	Step = Step or 22.5
	if EAng < SAng then 
		EAng, SAng = SAng, EAng 
	end
	local a, px, py, ox, oy, Rad = false,0,0,0,0,0
	repeat
		a = a and math.min(a +Step,EAng) or SAng
		Rad = (a -90) *math.pi /180
		px, py = x +R *math.cos(Rad), y +R *math.sin(Rad)
		if a ~= SAng then
			if Fill then
				screen.drawTriangleF(x, y, ox, oy, px, py)
			else
				screen.drawLine(ox, oy, px, py)
			end
		end
		ox, oy = px, py
	until(a >= EAng)
end

function drawLineInd(cx, cy, R, Val, MaxV, SAng, EAng)
    VRad = (Val /MaxV *((EAng-SAng)/360) *math.pi *2) +(90 *math.pi/180)
    SRad = SAng *(math.pi/180)
    ERad = EAng *(math.pi/180)
    Rad = VRad +SRad
    screen.drawLine( cx, cy, cx +R *math.cos(Rad), cy +R *math.sin(Rad))
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()
    cx = w/2
    cy = h/2
    Rng1,Rng2 = map.mapToScreen(0,0,Zoom,w,h,MaxDist,0)
    Range = Rng1-w/2

    screen.drawMap(GPSX, GPSY, Zoom)
    screen.setColor(200, 100, 0)
    drawArc(cx, cy, Range/4, 0, 360, false, 18)
    drawArc(cx, cy, Range/4*2, 0, 360, false, 18)
    drawArc(cx, cy, Range/4*3, 0, 360, false, 18)
    drawLineInd(cx, cy, Range, Compass, 1, 0, 360)
    drawLineInd(cx, cy, Range, Compass, 1, 90, 450)
    drawLineInd(cx, cy, Range, Compass, 1, 270, 630)

    screen.setColor(150, 25, 0)
    drawLineInd(cx, cy, Range, Compass, 1, 180, 540)

    screen.setColor(200, 0, 0)
    drawArc(cx, cy, Range, 0, 360, false, 18)
    drawLineInd(cx, cy, Range, RadarRot+Compass, 1, 180, 540)

    screen.setColor(255, 0, 0)
    for i, tgt in ipairs(Tgts) do
        local ElevRad = tgt.Elev*(2*math.pi)
        local RotRad = (tgt.Rot+Compass)*(2*math.pi)
        local gDist = tgt.Dist/math.cos(ElevRad)
        local AltDif = (tgt.Dist*math.tan(ElevRad))+Altitude
        local TgtX = GPSX+gDist*math.sin(RotRad)
        local TgtY = GPSY+gDist*math.cos(RotRad)
        local x, y = map.mapToScreen(GPSX, GPSY, Zoom, w, h, TgtX, TgtY)
        screen.drawCircleF(x, y, 2)
    end
end