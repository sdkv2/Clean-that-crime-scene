-- cutscene.lua

-- Define the cutscene class
local cutscene = {}
local textAlpha = 0
local fadeOut = false
local timer = 0
local fadeComplete = false
local state = "fadeIn"
local cutscene = {}
local anim8 = require 'libraries.anim8'
local bowlingGraphic = love.graphics.newImage('sprites/bowlingball.png')
local g = anim8.newGrid(32, 32, bowlingGraphic:getWidth(), bowlingGraphic:getHeight())
local bowlingball = anim8.newAnimation(g('1-10', 1), 0.05)
local offsetBowling = false
local drop = love.audio.newSource("sfx/drop.mp3", "static") -- the "static" tells LÖVE to load the file into memory, good for short sound effects
local hit = love.audio.newSource("sfx/hit.wav", "static")
local bowlingballY = 400
local kiranSprite = love.graphics.newImage('sprites/kiransprite.png')
local kiranFallen = love.graphics.newImage('sprites/kiranfallen.png')
-- Constructor
function cutscene:init()
    self.target = kyle
    self.bowlingObject = {x = 950, y = 400}
    self.moveOn = false
    kyle:setX(600)
    kyle:setY(400) 
    kyle.currentAnimation = kyle.animations.right
    self.borderRect = {}
    self.complete = false
    chat:chat('kyle', '1', function () self:goNext()
        
    end)
    -- Initialize the cutscene here
end

function cutscene:goNext()
    self.moveOn = true
    print('moving on')
end

-- Update method
function cutscene:update(dt)
    if state == "fadeIn" then
        self:fadeText(dt)
        if fadeComplete then
            state = "chat"
        end
    elseif state == "chat" then
        kyle.collider:setLinearVelocity(100, 0)
        chat:update(dt)
        print(kyle.collider:getLinearVelocity())
        if kyle.collider:getX() > 950 then
            kyle.currentAnimation = kyle.animations.downidle
            offsetBowling = true
            kyle.collider:setLinearVelocity(0, 0)
            if self.moveOn then
                self.moveOn = false
                chat:chat('kyle', '2', function () self:dropBowlingBall() end)
            end
        end
    elseif state == "chat2" then
        bowlingball:update(dt)
        chat:update(dt)
        if bowlingballY > 800 then
            hit:play()
            state = "chat3"
        else
            bowlingballY = bowlingballY + 200 * dt
            self.bowlingObject = {x = 950, y = bowlingballY}
        end
        cutscene.target = self.bowlingObject
    elseif state == "chat3" then
        if bowlingballY < 850 then
            bowlingball:update(dt)
            bowlingballY = bowlingballY + 200 * dt
        else
            cutscene.target = kyle
            chat:chat('kyle', '3', function () self:goNext() end)
        end
        


    end
end

function cutscene:dropBowlingBall()
    state = "chat2"
    cutscene.target = self.bowlingObject
    drop:play()
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
    if offsetBowling then
        bowlingball:draw(bowlingGraphic, kyle.collider:getX() - kyle.width/2, bowlingballY, nil, 0.75)
    elseif state == "chat" then
        bowlingball:draw(bowlingGraphic, kyle.collider:getX() - kyle.width/2, kyle.collider:getY() - kyle.height/2 + 25, nil, 0.75)
    end

    if state == "chat2" then
        love.graphics.draw(kiranSprite, 920, 750, 0, 1.5, 1.5)
    end
    if state == "chat3" then
        love.graphics.draw(kiranFallen, 920, 780, 0, 1.5, 1.5)
    end
    

end

function cutscene:drawText()
    if state == "fadeIn" then
        love.graphics.setColor(1, 1, 1, textAlpha)  -- Set the color with the alpha value
        love.graphics.print('In a mansion... somewhere in the English countryside', w/2-600, h/2)
        love.graphics.setColor(1, 1, 1, 1)  -- Reset the color
    end
end
-- Return the cutscene class
return cutscene