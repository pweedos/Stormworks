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
    simulator:setScreen(1, "3x3")
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
        simulator:setInputNumber(8, simulator:getSlider(2) * 50000)--Target Distance
        simulator:setInputNumber(9, simulator:getSlider(3)*0.5)--Target Azimuth
        simulator:setInputNumber(10, simulator:getSlider(4)*0.1)--Target Elevation
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

k=0
Rng = 1
tick = 0
Tgts = {}
function onTick()
    RadarRot = gN(7)
    TgtDist = gN(8)
    TgtX = gN(9)
    TgtY = gN(10)
    MaxDist = pN("Max Radar Distance")
    
    Touch1 = gB(1)
    TgtFound = gB(4)

    Range = MaxDist*Rng
    TgtYrad = TgtY*(2*math.pi)
    gDist = TgtDist/math.cos(TgtYrad)
    AltDif = TgtDist*math.tan(TgtYrad)
    tick = tick + 1
    if not Touch1 then
        k=0
    else
        k=k+1
    end
    if k==1 then
        Pulse=true
    else
        Pulse=false
    end
    if Pulse and Rng == 1 then
        Rng = 0.25
    elseif Pulse and Rng == 0.25 then
        Rng = 0.5
    elseif Pulse and Rng == 0.5 then
        Rng = 0.75
    elseif Pulse and Rng == 0.75 then
        Rng = 1
    end
    while RadarRot >= 1 do
        RadarRot = RadarRot - 1
    end
    if TgtFound and TgtX <= 0.03 and TgtX >= -0.03 then
        tgt = {Rot = RadarRot, AltDif = AltDif, Dist = gDist, Time = tick}
        table.insert(Tgts, tgt)
    end
    for i, tgt in ipairs(Tgts) do
        if tick - tgt.Time >= 300 or tick - tgt.Time <= -300 then
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
    screen.setColor(200, 100, 0)
    drawArc(cx, cy, cy/4, 0, 360, false, 18)
    drawArc(cx, cy, cy/4*2, 0, 360, false, 18)
    drawArc(cx, cy, cy/4*3, 0, 360, false, 18)
    drawLineInd(cx, cy, cy, 0, 1, 0, 360)
    drawLineInd(cx, cy, cy, 0, 1, 90, 450)
    drawLineInd(cx, cy, cy, 0, 1, 180, 540)
    drawLineInd(cx, cy, cy, 0, 1, 270, 630)

    screen.setColor(200, 0, 0)
    drawArc(cx, cy, cy, 0, 360, false, 18)
    drawLineInd(cx, cy, cy, RadarRot, 1, 180, 540)

    screen.setColor(200, 200, 200)
    screen.drawTextBox(0, 0, w, 7, string.format("%.0f",Range), -1, 0)
    for i, tgt in ipairs(Tgts) do
        local Rad = (tgt.Rot-0.25)*2*math.pi
        local x = cx+(tgt.Dist/Range*cy*math.cos(Rad))
        local y = cy+(tgt.Dist/Range*cy*math.sin(Rad))
        local z = tgt.AltDif
        screen.setColor(0, 0, 0)
        screen.drawRectF(x-10, y+2, 20, 7)
        screen.setColor(200, 200, 200)
        screen.drawCircleF(x, y, 0.3)
        screen.drawTextBox(x-10, y+2, 20, 7, string.format("%.0fm",z),0,0)
    end
end