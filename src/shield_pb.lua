--system.update()

local handlers = {}
handlers['Toggle'] = function() shield.toggle() end
handlers['StartVent'] = function() shield.startVenting() end
handlers['StopVent'] = function() shield.stopVenting() end

for key, screen in pairs(screens) do -- updating screens
    local output = screen.getScriptOutput()
    if #output > 0 then
        screen.clearScriptOutput()
        if handlers[output] then 
            handlers[output]() 
        else
            local json = require('dkjson')
            local res = json.decode(output) or {}  
            shield.setResistances(res[1],res[2],res[3],res[4])
        end
    end
end


--unit.start()

RGBcolor1 = "201,164,61" --export: Shield Bar, Highlight and Update color
RGBcolor2 = "135,206,235" --export: Outlines, Text and Controls color
RGBbackground = "0,26,26" --export: Background color

TTA_Logo = false --export:
FOX_Logo = true --export: 

function validateComp(n,dc)
    local c = n
    if type(n)~="number" then
        c=dc
    else
        if n>255 then c=255 end
        if n<0 then c=0 end
    end    
    return c
end

function validateRGB(t,d)
    local o = {}
    if #t~=3 then
        o = d
    else
        o[1] = validateComp(t[1],d[1])
        o[2] = validateComp(t[2],d[2])
        o[3] = validateComp(t[3],d[3])
    end
    return o
end

function colorSplit(col)
    local colt = {}
    for match in (col..","):gmatch("(.-),") do
        table.insert(colt, tonumber(match));
    end   
    return colt
end

color1 = colorSplit(RGBcolor1)
color2 = colorSplit(RGBcolor2)
bg = colorSplit(RGBbackground)

color1 = validateRGB(color1,{201,164,61})
color2 = validateRGB(color2,{135,206,235})
bg = validateRGB(bg,{0,26,26})

local FOXlogo = [[
    local fontf = getFont('Montserrat-Bold',15)
    setDefaultFillColor(layer, Shape_Polygon, color.r, color.g, color.b, 1)
    setDefaultFillColor(layer, Shape_Box, color.r, color.g, color.b, 1)
    setDefaultStrokeColor(layer, Shape_Box, color.r, color.g, color.b, 1)
    setDefaultStrokeWidth(layer, Shape_Box, 0)
    setDefaultStrokeColor(layer, Shape_Polygon, color.r, color.g, color.b, 1)
    setDefaultStrokeWidth(layer, Shape_Polygon, 0)
    addBox(layer, rx/2 -3, ry -45, 6, 6)
    addQuad(layer, rx/2 +3, ry -45, rx/2 +9, ry -51, rx/2 +15, ry -51, rx/2 +3, ry -39)
    addQuad(layer, rx/2 -3, ry -45, rx/2 -9, ry -51, rx/2 -15, ry -51, rx/2 -3, ry -39)
    addBox(layer, rx/2 -15, ry -69, 6, 18)
    addBox(layer, rx/2 +9, ry -69, 6, 18)
    addTriangle(layer, rx/2 -15, ry -69, rx/2 -15, ry -81, rx/2 -3, ry -69)
    addTriangle(layer, rx/2 +15, ry -69, rx/2 +15, ry -81, rx/2 +3, ry -69)
    setNextTextAlign(layer, AlignH_Center, AlignV_Bottom)
    setDefaultFillColor(layer, Shape_Text, color.r, color.g, color.b, 1)
    addText(layer, fontf, 'FOX Technology', rx/2, ry - 15)
]]

local TTAlogo = [[
    setDefaultStrokeColor(layer, Shape_Polygon, color.r, color.g, color.b, 1)
    setDefaultStrokeWidth(layer, Shape_Polygon, 0)
    setDefaultFillColor(layer, Shape_Polygon, 1, 1, 1, 1)
    addQuad(layer, rx/2 -3, ry -25, rx/2 -8, ry -30, rx/2 -8, ry -10, rx/2 -3, ry -5)
    addQuad(layer, rx/2 +8, ry -30, rx/2 +3, ry -25, rx/2 +3, ry -5, rx/2 +8, ry -10)
    addQuad(layer, rx/2 -50, ry -55, rx/2 -45, ry -50, rx/2 -8, ry -50, rx/2 -8, ry -55)
    addQuad(layer, rx/2 -40, ry -45, rx/2 -35, ry -40, rx/2 -8, ry -40, rx/2 -8, ry -45)
    addQuad(layer, rx/2 +50, ry -55, rx/2 +45, ry -50, rx/2 +8, ry -50, rx/2 +8, ry -55)
    addQuad(layer, rx/2 +40, ry -45, rx/2 +35, ry -40, rx/2 +8, ry -40, rx/2 +8, ry -45)
    setDefaultFillColor(layer, Shape_Polygon, color.r, color.g, color.b, 1)
    addQuad(layer, rx/2 -50, ry -75, rx/2 -45, ry -70, rx/2 +45, ry -70, rx/2 +50, ry -75)
    addQuad(layer, rx/2 -40, ry -65, rx/2 -35, ry -60, rx/2 -8, ry -60, rx/2 -3, ry -65)
    addQuad(layer, rx/2 +3, ry -65, rx/2 +8, ry -60, rx/2 +35, ry -60, rx/2 +40, ry -65)
    addQuad(layer, rx/2 -8, ry -60, rx/2 -3, ry -65, rx/2 -3, ry -25, rx/2 -8, ry -30)
    addQuad(layer, rx/2 +3, ry -65, rx/2 +8, ry -60, rx/2 +8, ry -30, rx/2 +3, ry -25)
]]

local screenLogo = [[]]

if TTA_Logo then screenLogo = TTAlogo end
if FOX_Logo then screenLogo = FOXlogo end

unit.hide()

screens={}

for e,f in pairs(unit)do 
    if type(f)=="table"and type(f.export)=="table"then
        if f.getElementClass then
            if f.getElementClass()=="ScreenUnit"then 
                screens[#screens+1]=f
            elseif string.sub(f.getElementClass(),1,6)=="Shield"then
                shield=f
            end 
        end 
    end 
end

if not next(screens) then
    system.print("No screen found")
    unit.exit()
end

if shield == nil then
   system.print("No shield found")
    unit.exit()
end

local params = {
    shieldState = shield.getState(),
    shieldHP = shield.getShieldHitpoints(),
    shieldMaxHP = shield.getMaxShieldHitpoints(),
    shieldIsVenting = shield.isVenting(),
    shieldVentingCooldown = shield.getVentingCooldown(),
    shieldVentingMaxCooldown = shield.getVentingMaxCooldown(),
    shieldResistances = shield.getResistances(),
    shieldResistancesCooldown = shield.getResistancesCooldown(),
    shieldResistancesMaxCooldown = shield.getResistancesMaxCooldown(),
    shieldResistancesPool = shield.getResistancesPool(),
    shieldResistancesRemaining = shield.getResistancesRemaining(),
    shieldStressRatio = shield.getStressRatioRaw(),
    lastTime = system.getTime()
}



local renderScript = [[

  --screen_rs.lua here

]]

for key, screen in pairs(screens) do -- updating screens
    screen.setScriptInput(json.encode(params))
    screen.setRenderScript(renderScript)
    screen.activate()
end



unit.setTimer('update',0.0001)



-- tick(update)

local params = {
    shieldState = shield.getState(),
    shieldHP = shield.getShieldHitpoints(),
    shieldMaxHP = shield.getMaxShieldHitpoints(),
    shieldIsVenting = shield.isVenting(),
    shieldVentingCooldown = shield.getVentingCooldown(),
    shieldVentingMaxCooldown = shield.getVentingMaxCooldown(),
    shieldResistances = shield.getResistances(),
    shieldResistancesCooldown = shield.getResistancesCooldown(),
    shieldResistancesMaxCooldown = shield.getResistancesMaxCooldown(),
    shieldResistancesPool = shield.getResistancesPool(),
    shieldResistancesRemaining = shield.getResistancesRemaining(),
    shieldStressRatio = shield.getStressRatioRaw(),
    lastTime = system.getTime()
}

for key, screen in pairs(screens) do -- updating screens
    screen.setScriptInput(json.encode(params))
end



