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


unit.hide()

screens={}

for e,f in pairs(unit)do 
    if type(f)=="table"and type(f.export)=="table"then
        if f.getElementClass then
            if f.getElementClass()=="ScreenUnit"then 
                screens[#screens+1]=f
            elseif f.getElementClass()=="ShieldGeneratorUnit"then 
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
