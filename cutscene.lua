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
local bowlingball2 = anim8.newAnimation(g('1-10', 1), 0.05)
local bowlingball2Y = 300
local offsetBowling = false
local drop = love.audio.newSource("sfx/drop.mp3", "static") -- the "static" tells LÖVE to load the file into memory, good for short sound effects
local hit = love.audio.newSource("sfx/hit.wav", "static")
local bowlingballY = 400
local kiranSprite = love.graphics.newImage('sprites/kiransprite.png')
local kiranFallen = love.graphics.newImage('sprites/kiranfallen.png')
local currentX = nil

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
            state = "chat4"
        end
    elseif state == "chat4" then
        chat:update(dt)
        if self.moveOn then
            self.moveOn = false
            kyle.currentAnimation = kyle.animations.down
            kyle.collider:setLinearVelocity(0, 200)
        end
        if kyle.collider:getY() >= 750 then
            print(kyle.collider:getX())
            kyle.currentAnimation = kyle.animations.right
            kyle.collider:setLinearVelocity(200, 0)
        end
        if kyle.collider:getY() > 780 then
            kyle.collider:setLinearVelocity(0, 0)
            kyle.currentAnimation = kyle.animations.leftidle
            state = "chat5"
            chat:chat('kyle', '4', function () self:goNext() end)
        elseif kyle.collider:getX() > 1000 then
            kyle.collider:setLinearVelocity(0, 200)
            kyle.currentAnimation = kyle.animations.down
        end
    elseif state == "chat5" then
        chat:update(dt)
        if self.moveOn then
            if bowlingball2Y > 800 then
                if not hit:isPlaying() then
                    kiranFallen = love.graphics.newImage('sprites/kirandead.png')
                    hit:play()
                end
                if bowlingball2Y < 825 then
                    bowlingball2:update(dt)
                    bowlingball2Y = bowlingball2Y + 200 * dt
                else 
                    state = "chat6"
                end
            else
                bowlingball2:update(dt)
                bowlingball2Y = bowlingball2Y + 200 * dt
            end
            

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
        bowlingball:draw(bowlingGraphic, 950, bowlingballY, nil, 0.75)
    elseif state == "chat" then
        bowlingball:draw(bowlingGraphic, kyle.collider:getX() - kyle.width/2, kyle.collider:getY() - kyle.height/2 + 25, nil, 0.75)
    end

    if state == "chat2" then
        love.graphics.draw(kiranSprite, 920, 750, 0, 1.5, 1.5)
    end
    if state == "chat3" then
        love.graphics.draw(kiranFallen, 920, 780, 0, 1.5, 1.5)
    end
    if state == "chat4" or state == "chat5" or state == "chat6" then
        love.graphics.draw(kiranFallen, 920, 780, 0, 1.5, 1.5)
        bowlingball2:draw(bowlingGraphic, 950, bowlingball2Y, nil, 0.75)
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