-- cutscene.lua

-- Define the cutscene class
local cutscene = {}
local textAlpha = 0
local fadeOut = false
local timer = 0
local fadeComplete = false

-- Constructor
function cutscene:init()
    self.borderRect = {}
    self.complete = false
    chat:chat('kyle', '1', function () self:moveOn()
        
    end)
    -- Initialize the cutscene here
end

function cutscene:moveOn()
    print('moving on')
end

-- Update method
function cutscene:update(dt)
    if not fadeComplete then
        self:fadeText(dt)
    else
        chat:update(dt)
    end
end


function cutscene:fadeText(dt)
    fade.fadeAmount = 1
    if textAlpha < 1 and not fadeOut then
        textAlpha = textAlpha + dt * 0.5  
    end

    if textAlpha >= 1 and not fadeOut then
        timer = timer + dt
        if timer >= 0.2 then
            fadeOut = true
        end
    end
    
    if fadeOut and textAlpha > 0 then
        textAlpha = textAlpha - dt * 0.5  -- Decrease the alpha value by half of dt
    elseif fadeOut and textAlpha <= 0 then
        fadeComplete = true
    end
end

function cutscene:draw()
    if self.borderRect then
        for num, rect in ipairs(self.borderRect) do
            love.graphics.setColor(1,1,1,1)
            love.graphics.rectangle('fill', rect.x, rect.y, rect.width , rect.height)
            love.graphics.setColor(0, 0, 0, 1) 
            love.graphics.rectangle('fill', rect.x, rect.y, rect.width, rect.height)
            love.graphics.setColor(1, 1, 1, 1) 
        end
    end
    love.graphics.setColor(1, 1, 1, textAlpha)  -- Set the color with the alpha value
    love.graphics.print('In a mansion... somewhere in the English countryside', w/2-600, h/2)
    love.graphics.setColor(1, 1, 1, 1)  -- Reset the color
end

-- Return the cutscene class
return cutscene