function drawLineInd(cx, cy, R, Val, MaxV, SAng, EAng)
    VRad = (Val /MaxV *((EAng-SAng)/360) *math.pi *2) +(90 *math.pi/180)
    SRad = SAng *(math.pi/180)
    ERad = EAng *(math.pi/180)
    Rad = VRad +SRad
    screen.drawLine( cx, cy, cx +R *math.cos(Rad), cy +R *math.sin(Rad))
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

function drawArc(cx, cy, R, SAng, EAng, Fill, Step)
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
		px, py = cx +R *math.cos(Rad), cy +R *math.sin(Rad)
		if a ~= SAng then
			if Fill then
				screen.drawTriangleF(cx, cy, ox, oy, px, py)
			else
				screen.drawLine(ox, oy, px, py)
			end
		end
		ox, oy = px, py
	until(a >= EAng)
end