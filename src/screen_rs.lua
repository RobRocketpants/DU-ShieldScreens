local json = require('dkjson')
local params = json.decode(getInput()) or {}

local newParams = not (lastUpdate == params.lastTime)
lastUpdate = params.lastTime
local setAMRes = params.shieldResistances[1]*100
local setEMRes = params.shieldResistances[2]*100
local setKNRes = params.shieldResistances[3]*100
local setTHRes = params.shieldResistances[4]*100
local AMStress = params.shieldStressRatio[1] 
local EMStress = params.shieldStressRatio[2]
local KNStress = params.shieldStressRatio[3]
local THStress = params.shieldStressRatio[4]
params.shieldResistancesPool = params.shieldResistancesPool*100

if not curAMRes then curAMRes = setAMRes end
if not curEMRes then curEMRes = setEMRes end
if not curKNRes then curKNRes = setKNRes end
if not curTHRes then curTHRes = setTHRes end



color = params.color or {r=]]..(color1[1]/255)..[[,g=]]..(color1[2]/255)..[[,b=]]..(color1[3]/255)..[[}
color2 = {r=]]..(color2[1]/255)..[[,g=]]..(color2[2]/255)..[[,b=]]..(color2[3]/255)..[[}



--------------------------------------------------------------------------------

local rx, ry = getResolution()
local layer = createLayer()
local debug_layer = createLayer()
local cx, cy = getCursor()

--local sx, sy = getTextBounds(font, message)
setDefaultStrokeColor(layer, Shape_Line, 1, 1, 1, 0.5)
setBackgroundColor(]]..(bg[1]/255)..[[,]]..(bg[2]/255)..[[,]]..(bg[3]/255)..[[)


--------------------------------------------------------------------------------

local fontCache = {}
function getFont (font, size)
    local k = font .. '_' .. tostring(size)
    if not fontCache[k] then fontCache[k] = loadFont(font, size) end
    return fontCache[k]
end

function drawCursor ()
    if cx < 0 then return end
    --addLine(layer, 0, cy, rx, cy)
    --addLine(layer, cx, 0, cx, ry)
    if getCursorDown() then
        setDefaultShadow(layer, Shape_Line, 32, color.r, color.g, color.b, 0.5)
    end
    --addLine(layer, cx - 12, cy - 12, cx - 7, cy - 12)
    --addLine(layer, cx - 12, cy - 12, cx - 12, cy - 7)
    --addLine(layer, cx + 7, cy - 12, cx + 12, cy - 12)
    --addLine(layer, cx + 12, cy - 12, cx + 12, cy - 7)
    --addLine(layer, cx - 12, cy + 7, cx - 12, cy + 12)
    --addLine(layer, cx - 12, cy + 12, cx -7, cy + 12)
    --addLine(layer, cx + 12, cy + 7, cx + 12, cy + 12)
    --addLine(layer, cx + 7, cy + 12, cx + 12, cy + 12)
    setDefaultShadow(layer, Shape_Line, 32, color.r, color.g, color.b, 0)
    addTriangle(layer, cx, cy, cx, cy + 20, cx + 15 , cy + 15)
    setNextStrokeWidth(layer, 2)
    setNextStrokeColor(layer, 1, 1, 1, 1)
    addLine(layer, cx + 3, cy + 8, cx + 11, cy + 26) 

end

function prettyStr (x)
    if type(x) == 'table' then
        local elems = {}
        for k, v in pairs(x) do
            table.insert(elems, string.format('%s = %s', prettyStr(k), prettyStr(v)))
        end
        return string.format('{%s}', table.concat(elems, ', '))
    elseif type(x) == 'number' then
        x = math.floor(x)
        --local left,num,right = string.match(x,'^([^%d]*%d)(%d*)(.-)$')
        --return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
        return tostring(math.floor(x)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
    else
        return tostring(x)
    end
end

function drawParams ()
    local font = getFont('RobotoMono', 11)
    setNextTextAlign(debug_layer, AlignH_Left, AlignV_Bottom)
    addText(debug_layer, font, "Script Parameters", 16, 180)
    local y = 196
    for k, v in pairs(params) do
        setNextTextAlign(debug_layer, AlignH_Left, AlignV_Bottom)
        addText(debug_layer, font, k .. ' = ' .. prettyStr(v), 24, y)
        y = y + 12
    end
    setNextTextAlign(debug_layer, AlignH_Left, AlignV_Bottom)
    addText(debug_layer, font, 'New = ' .. prettyStr(AMStress), 24, y)
    y = y + 12
    for k, v in pairs(params.shieldResistances) do
        setNextTextAlign(debug_layer, AlignH_Left, AlignV_Bottom)
        addText(debug_layer, font, k .. ' = ' .. tostring(v*100), 24, y)
        y = y + 12
    end
end

function drawShieldBar ()
    local fontl = getFont('Play-Bold', 30)
    local fontm = getFont('Play-Bold', 25)
    local fonts = getFont('Play-Bold', 14)

    if params.shieldState == 1 then message = '' else message = 'INACTIVE' end
    if params.shieldMaxHP == 0 then message = 'SHIELD BP BUG - PICK UP AND DROP SHIELD' end
    
    setNextTextAlign(layer, AlignH_Left, AlignV_Bottom)
    setDefaultFillColor(layer,Shape_Text, color.r, color.g, color.b, 1.0)
    addText(layer, fontl, prettyStr(params.shieldHP), 32,70)
    sx, sy = getTextBounds(fontl, prettyStr(params.shieldHP))
    setNextTextAlign(layer, AlignH_Right, AlignV_Bottom)
    if params.shieldMaxHP == 0 then
        addText(layer, fontm, '0%', rx - 32,70)
    else
        addText(layer, fontm, prettyStr((params.shieldHP/params.shieldMaxHP)*100)..'%', rx - 32,70)
    end
    
        
    setNextTextAlign(layer, AlignH_Left, AlignV_Bottom)
    setDefaultFillColor(layer,Shape_Text, color2.r, color2.g, color2.b, .5)
    addText(layer, fontm, ' / '..prettyStr(params.shieldMaxHP), 32 + sx,70)
    
    setNextTextAlign(layer, AlignH_Left, AlignV_Bottom)
    addText(layer, fontm, 'GENERATED SHIELD', 32, 32)
    setNextTextAlign(layer, AlignH_Left, AlignV_Bottom)
    addText(layer, fonts, 'LOW', 32, 146)
    setNextTextAlign(layer, AlignH_Center, AlignV_Bottom)
    addText(layer, fonts, 'MEDIUM', rx/2, 146)
    setNextTextAlign(layer, AlignH_Right, AlignV_Bottom)
    addText(layer, fonts, 'HIGH', rx - 32, 146)
    
    setDefaultFillColor(layer,Shape_Text, color2.r, color2.g, color2.b, 1)
    setNextTextAlign(layer, AlignH_Left, AlignV_Bottom)
    addText(layer, fonts, '0', 32, 162)
    setNextTextAlign(layer, AlignH_Center, AlignV_Bottom)
    addText(layer, fonts, prettyStr(params.shieldMaxHP/2), rx/2, 162)
    setNextTextAlign(layer, AlignH_Right, AlignV_Bottom)
    addText(layer, fonts, prettyStr(params.shieldMaxHP), rx - 32, 162)


    
    setNextFillColor(layer, 0,0,0, 0)
    setNextStrokeColor(layer, 1, 1, 1, 1)
    setNextStrokeWidth(layer, 2)
    addBoxRounded(layer, 32, 82, rx - 64, 48, 8)
    setNextShadow(layer, 64, color.r, color.g, color.b, 0.4)
    setNextFillColor(layer, color.r, color.g, color.b, 0.5+(0.5*params.shieldState))
    if params.shieldMaxHP > 0 then
        addBoxRounded(layer, 32, 82, (rx - 64)*(params.shieldHP/params.shieldMaxHP), 48, 8)
        setNextFillColor(layer, 0, 0, 0, .3)
    end
    
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    addText(layer, fontl, message, rx/2,106) 
end

function drawButtons ()
    local fonts = getFont('Play-Bold', 25)
    if params.shieldState == 0 then
        setNextFillColor(layer, 0,0,0, 0)
        setDefaultFillColor(layer, Shape_Text, color2.r, color2.g, color2.b, 1)
        buttontext = "ACTIVATE"
    else
        setNextFillColor(layer, color.r,color.g,color.b, 1)
        setDefaultFillColor(layer, Shape_Text, 0, 0, 0, 0.7)
        buttontext = "DEACTIVATE"
    end
    
    if params.shieldIsVenting == 1 then
        vtext = "STOP VENTING"
    else
        if params.shieldVentingCooldown > 0 then
            vtext = 'VENT COOLDOWN '..prettyStr(params.shieldVentingCooldown)
        else
            vtext = "START VENTING"
        end
    end
    
    if cx > 32 and cx < 332 and cy > (ry - 80) and cy < (ry - 32) then
        shade = 32
        if getCursorPressed() then setOutput('Toggle') end
    else
        shade = 8
    end
    
    if cx > (rx - 332) and cx < (rx - 32) and cy > (ry - 80) and cy < (ry - 32) then
        vshade = 32
        if getCursorPressed() then 
            if params.shieldIsVenting == 1 then setOutput('StopVent') else setOutput('StartVent') end
        end
    else
        vshade = 8
    end
    
    
    setNextStrokeColor(layer, color2.r, color2.g, color2.b, 1)
    setNextStrokeWidth(layer, 1)
    setNextShadow(layer, shade, color2.r, color2.g, color2.b, 0.4)
    addBoxRounded(layer, 32, ry - 80, 300, 48, 2)
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    addText(layer, fonts, buttontext, 182,ry - 56) 

    setNextFillColor(layer, color.r,color.g,color.b, 1)
    setNextStrokeColor(layer, color2.r, color2.g, color2.b, 1)
    setNextStrokeWidth(layer, 1)
    setNextShadow(layer, vshade, color2.r, color2.g, color2.b, 0.4)
    addBoxRounded(layer, rx - 332, ry - 80, 300, 48, 2)
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    setNextFillColor(layer, 0,0,0, 0.7)
    addText(layer, fonts, vtext, rx - 182,ry - 56) 
    
    if curAMRes==setAMRes and curEMRes==setEMRes and curKNRes==setKNRes and curTHRes==setTHRes then
        canSet=0
        setDefaultFillColor(layer, Shape_Text,1,1,1, 0.5)
    else
        canSet=1
        setDefaultFillColor(layer, Shape_Text,0,0,0, 0.7)
    end
    
    setNextFillColor(layer,color2.r,color2.g,color2.b,1)
    setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
    addText(layer, fonts, '/ '..prettyStr(params.shieldResistancesPool), 198,242)
    if canSet==1 then
        setNextFillColor(layer,color.r,color.g,color.b,1)
    else
        setNextFillColor(layer,color2.r,color2.g,color2.b,1)
    end
    setNextTextAlign(layer, AlignH_Right, AlignV_Middle)
    addText(layer, fonts, prettyStr(params.shieldResistancesPool-curAMRes-curEMRes-curKNRes-curTHRes), 190,242)
    
    if params.shieldResistancesCooldown > 0 then
        settext = 'SET COOLDOWN '..prettyStr(params.shieldResistancesCooldown)
        canSet=0
    else
        settext = 'SET'
    end
    
    if cx > 64 and cx < 332 and cy > 345 and cy < 393 and canSet==1 then
        setshade = 16
        if getCursorPressed() then
            local resout = {curAMRes/100, curEMRes/100, curKNRes/100, curTHRes/100}
            setOutput(json.encode(resout))    
        end
    else
        setshade = 8
    end
    
    setNextFillColor(layer, color.r,color.g,color.b, canSet)        
    setNextStrokeColor(layer, color2.r, color2.g, color2.b, 1)
    setNextStrokeWidth(layer, 1)
    setNextShadow(layer, setshade, color2.r, color2.g, color2.b, 0.4)
    addBoxRounded(layer, 64, 345, 268, 48, 2)
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    addText(layer, fonts, settext, 198,369) 
    
    if cx > 64 and cx < 332 and cy > 405 and cy < 453 then
        reshade = 16
        if getCursorPressed() then
            curAMRes=0
            curEMRes=0
            curKNRes=0
            curTHRes=0
        end
    else
        reshade = 8
    end

    setNextFillColor(layer, 0,0,0,0)        
    setNextStrokeColor(layer, color2.r, color2.g, color2.b, 1)
    setNextStrokeWidth(layer, 1)
    setNextShadow(layer, reshade, color2.r, color2.g, color2.b, 0.4)
    addBoxRounded(layer, 64, 405, 268, 48, 2)
    setNextFillColor(layer, color2.r, color2.g, color2.b, 1)
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    addText(layer, fonts, 'RESET', 198,429) 

    
end

function drawPBWarn ( message )
    pb_layer = createLayer()
    setNextFillColor(pb_layer, 0, 0, 0, .8)
    addBox(pb_layer, 0, 0, rx, ry)
    --message='START THE PROGRAMMING BOARD TO USE'
    local wfont = getFont('Play-Bold', 40)
    local sx, sy = getTextBounds(wfont, message)

    
    setDefaultStrokeColor(pb_layer, Shape_Line, 1, 1, 1, 0.5)
    setNextShadow(pb_layer, 64, color.r, color.g, color.b, 0.4)
    setNextFillColor(pb_layer, color.r, color.g, color.b, 1.0)
    addBoxRounded(pb_layer, (rx-sx-16)/2, (ry-sy-16)/2, sx+16, sy+16, 8)
    setNextFillColor(pb_layer, 0, 0, 0, 1)
    setNextTextAlign(pb_layer, AlignH_Center, AlignV_Middle)
    addText(pb_layer, wfont, message, rx/2,ry/2)
    
end

function drawResSettings ()
    setNextFillColor(layer, color2.r, color2.g, color2.b, 0.05)
    addBox(layer, 32, 176, rx - 64, ry - 268)
    stage = 25
    local wfont = getFont('Play-Bold', 12)
    local nfont = getFont('Play-Bold', 15)
    
    setDefaultFillColor(layer, Shape_Box, color2.r,color2.g,color2.b, 0.2)
    addBox(layer, 384, 225, 220, 35)
    addBox(layer, 384, 285, 220, 35)
    addBox(layer, 384, 345, 220, 35)
    addBox(layer, 384, 405, 220, 35)
    setDefaultFillColor(layer, Shape_Box, color2.r,color2.g,color2.b, 0.1)
    addBox(layer, 604, 225, 360, 33)--242
    addBox(layer, 604, 285, 360, 33)--302
    addBox(layer, 604, 345, 360, 33)--362
    addBox(layer, 604, 405, 360, 33)--422
    setDefaultFillColor(layer, Shape_Text, color2.r,color2.g,color2.b, 1)
    setNextTextAlign(layer, AlignH_Center, AlignV_Bottom)
    addText(layer, wfont, 'ENERGY POOL', 198, 220)
    setNextTextAlign(layer, AlignH_Left, AlignV_Bottom)
    addText(layer, wfont, 'SHIELD SETTINGS (%)', 384, 220)
    setNextTextAlign(layer, AlignH_Left, AlignV_Bottom)
    addText(layer, wfont, 'STRESS', 860, 220)
    setDefaultFillColor(layer, Shape_Text, color2.r,color2.g,color2.b, 0.5)
    setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
    addText(layer, wfont, 'ANTIMATTER', 400, 242)
    setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
    addText(layer, wfont, 'ELECTROMAGNETIC', 400, 302)
    setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
    addText(layer, wfont, 'KINETIC', 400, 362)
    setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
    addText(layer, wfont, 'THERMAL', 400, 422)
    setNextTextAlign(layer, AlignH_Center, AlignV_Top)
    addText(layer, wfont, 'Base', 623, 229)
    setNextTextAlign(layer, AlignH_Center, AlignV_Top)
    addText(layer, nfont, '10', 623, 242)
    setNextTextAlign(layer, AlignH_Center, AlignV_Top)
    addText(layer, wfont, 'Base', 623, 289)
    setNextTextAlign(layer, AlignH_Center, AlignV_Top)
    addText(layer, nfont, '10', 623, 302)
    setNextTextAlign(layer, AlignH_Center, AlignV_Top)
    addText(layer, wfont, 'Base', 623, 349)
    setNextTextAlign(layer, AlignH_Center, AlignV_Top)
    addText(layer, nfont, '10', 623, 362)
    setNextTextAlign(layer, AlignH_Center, AlignV_Top)
    addText(layer, wfont, 'Base', 623, 409)
    setNextTextAlign(layer, AlignH_Center, AlignV_Top)
    addText(layer, nfont, '10', 623, 422)
    setDefaultFillColor(layer, Shape_Box, 0,0,0,0)
    setDefaultStrokeColor(layer, Shape_Box, 0,0.1,0.1, 1)
    setDefaultStrokeWidth(layer, Shape_Box, 1)
    addBox(layer, 800, 233, 150, 18)
    addBox(layer, 800, 293, 150, 18)
    addBox(layer, 800, 353, 150, 18)
    addBox(layer, 800, 413, 150, 18)
    setNextFillColor(layer, 1, 0, 0, .7)
    setNextShadow(layer, 8, 1, 0, 0, AMStress)
    addBox(layer, 800, 233, 150*AMStress, 18)
    setNextFillColor(layer, 1, 0, 0, .7)
    setNextShadow(layer, 8, 1, 0, 0, EMStress)
    addBox(layer, 800, 293, 150*EMStress, 18)
    setNextFillColor(layer, 1, 0, 0, .7)
    setNextShadow(layer, 8, 1, 0, 0, KNStress)
    addBox(layer, 800, 353, 150*KNStress, 18)
    setNextFillColor(layer, 1, 0, 0, .7)
    setNextShadow(layer, 8, 1, 0, 0, THStress)
    addBox(layer, 800, 413, 150*THStress, 18)
    setDefaultStrokeColor(layer, Shape_Line, color2.r,color2.g,color2.b, 0.2)
    addLine(layer,354,267,384,267)
    addLine(layer,354,327,384,327)
    addLine(layer,354,387,384,387)
    addLine(layer,354,447,384,447)
    addLine(layer,354,267,354,447)
    addLine(layer,198,300,354,300)
    addLine(layer,198,260,198,300)
    setNextStrokeColor(layer,color2.r,color2.g,color2.b, 0.2)
    addBox(layer,64,225,268,35)
    
    setNextFillColor(layer, 0,0,0, 0)
    setNextStrokeColor(layer, 0,0.1,0.1, 1)
    setNextStrokeWidth(layer, 1)
    addBox(layer, 384, 260, 350, 15)
    if cx > 384 and cx < 874 and cy > 260 and cy < 275 then
        if getCursorDown() then
            curAMRes = 0
            if cx > 384+stage*2 then if (curEMRes+curKNRes+curTHRes)<=55 then curAMRes = 5 end end
            if cx > 384+stage*3 then if (curEMRes+curKNRes+curTHRes)<=50 then curAMRes = 10 end end
            if cx > 384+stage*4 then if (curEMRes+curKNRes+curTHRes)<=45 then curAMRes = 15 end end
            if cx > 384+stage*5 then if (curEMRes+curKNRes+curTHRes)<=40 then curAMRes = 20 end end
            if cx > 384+stage*6 then if (curEMRes+curKNRes+curTHRes)<=35 then curAMRes = 25 end end
            if cx > 384+stage*7 then if (curEMRes+curKNRes+curTHRes)<=30 then curAMRes = 30 end end
            if cx > 384+stage*8 then if (curEMRes+curKNRes+curTHRes)<=25 then curAMRes = 35 end end
            if cx > 384+stage*9 then if (curEMRes+curKNRes+curTHRes)<=20 then curAMRes = 40 end end
            if cx > 384+stage*10 then if (curEMRes+curKNRes+curTHRes)<=15 then curAMRes = 45 end end
            if cx > 384+stage*11 then if (curEMRes+curKNRes+curTHRes)<=10 then curAMRes = 50 end end
            if cx > 384+stage*12 then if (curEMRes+curKNRes+curTHRes)<=5 then curAMRes = 55 end end
            if cx > 384+stage*13 then if (curEMRes+curKNRes+curTHRes)==0 then curAMRes = 60 end end
        end
    end
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
    addText(layer, nfont, '+'..prettyStr(curAMRes), 663, 242)
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    if curAMRes == setAMRes then
        setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
        addText(layer, nfont, prettyStr(curAMRes+10), 703, 242)
        setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
    else
        setNextFillColor(layer, color.r,color.g,color.b, 1)
        addText(layer, nfont, prettyStr(curAMRes+10), 703, 242)
        setNextFillColor(layer, color.r,color.g,color.b, 1)
    end
    addBox(layer, 384, 260, stage*(curAMRes/5+2), 15)
    setNextStrokeWidth(layer, 2)
    setNextStrokeColor(layer, 1, 1, 1, 1)
    addLine(layer, 384+(stage*(setAMRes/5+2)), 260, 384+(stage*(setAMRes/5+2)), 275)

    
    setNextFillColor(layer, 0,0,0, 0)
    setNextStrokeColor(layer, 0,0.1,0.1, 1)
    setNextStrokeWidth(layer, 1)
    addBox(layer, 384, 320, 350, 15)
    if cx > 384 and cx < 874 and cy > 320 and cy < 335 then
        if getCursorDown() then
            curEMRes = 0
            if cx > 384+stage*2 then if (curAMRes+curKNRes+curTHRes)<=55 then curEMRes = 5 end end
            if cx > 384+stage*3 then if (curAMRes+curKNRes+curTHRes)<=50 then curEMRes = 10 end end
            if cx > 384+stage*4 then if (curAMRes+curKNRes+curTHRes)<=45 then curEMRes = 15 end end
            if cx > 384+stage*5 then if (curAMRes+curKNRes+curTHRes)<=40 then curEMRes = 20 end end
            if cx > 384+stage*6 then if (curAMRes+curKNRes+curTHRes)<=35 then curEMRes = 25 end end
            if cx > 384+stage*7 then if (curAMRes+curKNRes+curTHRes)<=30 then curEMRes = 30 end end
            if cx > 384+stage*8 then if (curAMRes+curKNRes+curTHRes)<=25 then curEMRes = 35 end end
            if cx > 384+stage*9 then if (curAMRes+curKNRes+curTHRes)<=20 then curEMRes = 40 end end
            if cx > 384+stage*10 then if (curAMRes+curKNRes+curTHRes)<=15 then curEMRes = 45 end end
            if cx > 384+stage*11 then if (curAMRes+curKNRes+curTHRes)<=10 then curEMRes = 50 end end
            if cx > 384+stage*12 then if (curAMRes+curKNRes+curTHRes)<=5 then curEMRes = 55 end end
            if cx > 384+stage*13 then if (curAMRes+curKNRes+curTHRes)==0 then curEMRes = 60 end end
        end
    end
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
    addText(layer, nfont, '+'..prettyStr(curEMRes), 663, 302)
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    if curEMRes == setEMRes then
        setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
        addText(layer, nfont, prettyStr(curEMRes+10), 703, 302)
        setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
    else
        setNextFillColor(layer, color.r,color.g,color.b, 1)
        addText(layer, nfont, prettyStr(curEMRes+10), 703, 302)
        setNextFillColor(layer, color.r,color.g,color.b, 1)
    end
    addBox(layer, 384, 320, stage*(curEMRes/5+2), 15)
    setNextStrokeWidth(layer, 2)
    setNextStrokeColor(layer, 1, 1, 1, 1)
    addLine(layer, 384+(stage*(setEMRes/5+2)), 320, 384+(stage*(setEMRes/5+2)), 335)
    
    setNextFillColor(layer, 0,0,0, 0)
    setNextStrokeColor(layer, 0,0.1,0.1, 1)
    setNextStrokeWidth(layer, 1)
    addBox(layer, 384, 380, 350, 15)
    if cx > 384 and cx < 874 and cy > 380 and cy < 395 then
        if getCursorDown() then
            curKNRes = 0
            if cx > 384+stage*2 then if (curAMRes+curEMRes+curTHRes)<=55 then curKNRes = 5 end end
            if cx > 384+stage*3 then if (curAMRes+curEMRes+curTHRes)<=50 then curKNRes = 10 end end
            if cx > 384+stage*4 then if (curAMRes+curEMRes+curTHRes)<=45 then curKNRes = 15 end end
            if cx > 384+stage*5 then if (curAMRes+curEMRes+curTHRes)<=40 then curKNRes = 20 end end
            if cx > 384+stage*6 then if (curAMRes+curEMRes+curTHRes)<=35 then curKNRes = 25 end end
            if cx > 384+stage*7 then if (curAMRes+curEMRes+curTHRes)<=30 then curKNRes = 30 end end
            if cx > 384+stage*8 then if (curAMRes+curEMRes+curTHRes)<=25 then curKNRes = 35 end end
            if cx > 384+stage*9 then if (curAMRes+curEMRes+curTHRes)<=20 then curKNRes = 40 end end
            if cx > 384+stage*10 then if (curAMRes+curEMRes+curTHRes)<=15 then curKNRes = 45 end end
            if cx > 384+stage*11 then if (curAMRes+curEMRes+curTHRes)<=10 then curKNRes = 50 end end
            if cx > 384+stage*12 then if (curAMRes+curEMRes+curTHRes)<=5 then curKNRes = 55 end end
            if cx > 384+stage*13 then if (curAMRes+curEMRes+curTHRes)==0 then curKNRes = 60 end end
        end
    end
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
    addText(layer, nfont, '+'..prettyStr(curKNRes), 663, 362)
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    if curKNRes == setKNRes then
        setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
        addText(layer, nfont, prettyStr(curKNRes+10), 703, 362)
        setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
    else
        setNextFillColor(layer, color.r,color.g,color.b, 1)
        addText(layer, nfont, prettyStr(curKNRes+10), 703, 362)
        setNextFillColor(layer, color.r,color.g,color.b, 1)
    end
    addBox(layer, 384, 380, stage*(curKNRes/5+2), 15)
    setNextStrokeWidth(layer, 2)
    setNextStrokeColor(layer, 1, 1, 1, 1)
    addLine(layer, 384+(stage*(setKNRes/5+2)), 380, 384+(stage*(setKNRes/5+2)), 395)
    
    setNextFillColor(layer, 0,0,0, 0)
    setNextStrokeColor(layer, 0,0.1,0.1, 1)
    setNextStrokeWidth(layer, 1)
    addBox(layer, 384, 440, 350, 15)
    if cx > 384 and cx < 874 and cy > 440 and cy < 455 then
        if getCursorDown() then
            curTHRes = 0
            if cx > 384+stage*2 then if (curAMRes+curEMRes+curKNRes)<=55 then curTHRes = 5 end end
            if cx > 384+stage*3 then if (curAMRes+curEMRes+curKNRes)<=50 then curTHRes = 10 end end
            if cx > 384+stage*4 then if (curAMRes+curEMRes+curKNRes)<=45 then curTHRes = 15 end end
            if cx > 384+stage*5 then if (curAMRes+curEMRes+curKNRes)<=40 then curTHRes = 20 end end
            if cx > 384+stage*6 then if (curAMRes+curEMRes+curKNRes)<=35 then curTHRes = 25 end end
            if cx > 384+stage*7 then if (curAMRes+curEMRes+curKNRes)<=30 then curTHRes = 30 end end
            if cx > 384+stage*8 then if (curAMRes+curEMRes+curKNRes)<=25 then curTHRes = 35 end end
            if cx > 384+stage*9 then if (curAMRes+curEMRes+curKNRes)<=20 then curTHRes = 40 end end
            if cx > 384+stage*10 then if (curAMRes+curEMRes+curKNRes)<=15 then curTHRes = 45 end end
            if cx > 384+stage*11 then if (curAMRes+curEMRes+curKNRes)<=10 then curTHRes = 50 end end
            if cx > 384+stage*12 then if (curAMRes+curEMRes+curKNRes)<=5 then curTHRes = 55 end end
            if cx > 384+stage*13 then if (curAMRes+curEMRes+curKNRes)==0 then curTHRes = 60 end end
        end
    end
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
    addText(layer, nfont, '+'..prettyStr(curTHRes), 663, 422)
    setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
    if curTHRes == setTHRes then
        setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
        addText(layer, nfont, prettyStr(curTHRes+10), 703, 422)
        setNextFillColor(layer, color2.r,color2.g,color2.b, 1)
    else
        setNextFillColor(layer, color.r,color.g,color.b, 1)
        addText(layer, nfont, prettyStr(curTHRes+10), 703, 422)
        setNextFillColor(layer, color.r,color.g,color.b, 1)
    end
    addBox(layer, 384, 440, stage*(curTHRes/5+2), 15)
    setNextStrokeWidth(layer, 2)
    setNextStrokeColor(layer, 1, 1, 1, 1)
    addLine(layer, 384+(stage*(setTHRes/5+2)), 440, 384+(stage*(setTHRes/5+2)), 455)
    
    ]]..screenLogo..[[
    
    
    
    
end

--------------------------------------------------------------------------------


drawCursor()
--drawParams()
drawShieldBar()
drawResSettings()
drawButtons()
if not newParams then drawPBWarn('START THE PROGRAMMING BOARD TO USE') end

requestAnimationFrame(1)


