-- fade.lua
local fade = {}

fade.fadeAmount = 1
fade.fadeTimer = 0.05
fade.fadeStarted = false
fade.isActive = false 

function fade.handleFade(dt)
    if fade.isActive then
        if not fade.fadeStarted then
            fade.fadeAmount = 1
            fade.fadeStarted = true
        end
        fade.fadeTimer = fade.fadeTimer - dt
        if fade.fadeTimer <= 0 then
            fade.fadeAmount = math.max(fade.fadeAmount - dt, 0)
            if fade.fadeAmount == 0 then
                fade.isActive = false
                fade.fadeTimer = 0.05
                fade.fadeStarted = false
            end
        end
    end
end

function fade.startFade()
    fade.isActive = true
end

function fade.draw()
    love.graphics.setColor(0, 0, 0, fade.fadeAmount)
    love.graphics.rectangle('fill', 0, 0, screenWidth * 3, screenHeight *3)
    love.graphics.setColor(1,1,1)
end

return fade