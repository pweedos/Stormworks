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
    simulator:setProperty("ExampleNumberProperty", 123)

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
        simulator:setInputBool(1, simulator:getIsToggled(1))--Full
        simulator:setInputBool(2, simulator:getIsToggled(2))--Horizontal
        simulator:setInputBool(3, simulator:getIsToggled(3))--Inverted
        simulator:setInputNumber(1, simulator:getSlider(1)*10)--Value

    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!


function onTick()
    Val = input.getNumber(1)
    Full = input.getBool(1)
    Hor = input.getBool(2)
    Inv = input.getBool(3)
end

function drawBarInd(x, y, w, h, Val, MinVal, MaxVal, Full, Hor, Inv)
    if Full then
        if not Hor then
            local Ph = (Val-MinVal)/(MaxVal-MinVal)*(h-MinVal)+MinVal
            if Inv then
                screen.drawRectF(x, y, w, Ph)
            else --not Inv
                local Py = h-Ph+1
                screen.drawRectF(x, Py, w, Ph)
            end
        else --Hor
            local Pw = (Val-MinVal)/(MaxVal-MinVal)*(w-MinVal)+MinVal
            if not Inv then
                screen.drawRectF(x, y, Pw, h)
            else --Inv
                local Px = w-Pw+1
                screen.drawRectF(Px, y, Pw, h)
            end
        end
    else --not Full
        if Hor then
            local Px = (Val-MinVal)/(MaxVal-MinVal)*(w-MinVal-1)+MinVal+1
            if not Inv then
                screen.drawLine(Px, y, Px, y+h)
            else --Inv
                local Pxi = w-Px+1
                screen.drawLine(Pxi, y, Pxi, y+h)
            end
        else --not Hor
            local Py = (Val-MinVal)/(MaxVal-MinVal)*(h-MinVal-1)+MinVal+1
            if Inv then
                screen.drawLine(x, Py, x+w, Py)
            else -- not Inv
                local Pyi = h-Py+1
                screen.drawLine(x, Pyi, x+w, Pyi)
            end
        end
    end
end

function drawLineInd(cx, cy, R, Val, MaxV, SAng, EAng)
    VRad = (Val /MaxV *((EAng-SAng)/360) *math.pi *2) +(90 *math.pi/180)
    SRad = SAng *(math.pi/180)
    ERad = EAng *(math.pi/180)
    Rad = VRad +SRad
    screen.drawLine( cx, cy, cx +R *math.cos(Rad), cy +R *math.sin(Rad))
end

function onDraw()
    sw = screen.getWidth()
    sh = screen.getHeight()
    x = 1
    y = 1
    w = sw-2
    h = sh-2
    MinVal = 0
    MaxVal = 10
    screen.setColor(255, 0, 0)
    drawBarInd(x, y, w, h, Val, MinVal, MaxVal, Full, Hor, Inv)
end



