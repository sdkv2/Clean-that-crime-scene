-- minigame1.lua
local Minigame2 = {}
Minigame2.__index = Minigame2
love.graphics.setDefaultFilter("nearest", "nearest")
local broomSprite = love.graphics.newImage('sprites/Broom.png')
local broomSpriteWidth = broomSprite:getWidth() * 2
local broomSpriteHeight = broomSprite:getHeight()
local handSprite = love.graphics.newImage('sprites/hand.png')
local broomX, broomY = 600, 500
local Reverse = false
local broomR = 0
local rectHeight = 100
local rectWidth = 0
local screenWidth, screenHeight = 0, 0
local handY = 0
local handX = 0
local currenTime = 0
local handWidth = handSprite:getWidth() * 3
local handHeight = handSprite:getHeight()
local handRaised = false
local handSpawned = false
local broomStopped = false
local score = 0
local tween = require 'libraries.tween'
local broomTween = nil
local ParentMinigame
local anim8 = require 'libraries.anim8'
local mouse = love.graphics.newImage('sprites/mouse.png')
local mouseClick = love.graphics.newImage('sprites/mouse_left.png')
local currentImage2 = mouse
local lastSwitch = love.timer.getTime()
local customFont = love.graphics.newFont('MS_PAIN.ttf', 72)
local allParticleData = require 'blood'
local trashChute = love.graphics.newImage('sprites/trashchute1.png')
local trashChute2 = love.graphics.newImage('sprites/trashchute2.png')
local trashChute3 = love.graphics.newImage('sprites/trashchute3.png')
local kiranLimb = love.graphics.newImage('sprites/kiranlimbs.png')
local g = anim8.newGrid(64, 128, kiranLimb:getWidth(), kiranLimb:getHeight())
local kiranLimbs = anim8.newAnimation(g('1-4', 1), 0.1)
local buttonSprite = love.graphics.newImage('sprites/button.png')
local g2 = anim8.newGrid(32, 32, buttonSprite:getWidth(), buttonSprite:getHeight())
local button = anim8.newAnimation(g2('1-2', 1), 0.1)
local chuteY = -900
function Minigame2.new(Parent)
    love.graphics.setFont(customFont)
    ParentMinigame = Parent
    screenWidth, screenHeight = love.graphics.getDimensions()
    rectWidth = screenWidth
    handY = screenHeight + handHeight
    local self = setmetatable({}, Minigame2)
    score = 0
    return self
end

function Minigame2:updateImages()
    if love.timer.getTime() - lastSwitch >= 0.5 then
        -- Switch the image
        if currentImage2 == mouseClick then
            currentImage2 = mouse
        else
            currentImage2 = mouseClick
        end

        -- Update the time of the last switch
        lastSwitch = love.timer.getTime()
    end
end
function Minigame2:spawnHand()
    handX = love.math.random(screenWidth * 0.2, screenWidth * 0.6)
end

function Minigame2:raiseHand(dt)
    handY = handY - 100 * dt
    if handY < screenHeight - handHeight * 3 - rectHeight then
        handY = screenHeight - handHeight * 3 - rectHeight
        handRaised = true
    end
end
function Minigame2:keypressed(key)
end

function Minigame2:broomWiggle(dt)
    
end
local broomTween = nil
local broomPos = {y = 0}
local UpwardTween = false
function Minigame2:broomMove(dt)
    if not broomStopped then
        broomR = broomR + 3 * math.pi * love.timer.getDelta()
        broomY = 200 + math.sin(broomR) * 5
        if Reverse then
            broomX = broomX - 400 * dt * (score > 1 and score or 1)
        else
            broomX = broomX + 400 * dt * (score > 1 and score or 1)
        end
        if broomX > screenWidth * 0.7 then
            Reverse = true
        elseif broomX < screenWidth * 0.2 then
            Reverse = false
        end
    else
        if broomTween == nil then
            broomPos.y = broomY
            broomTween = tween.new(1, broomPos, {y = screenHeight - 300}, 'inQuad')
        else
            local complete = broomTween:update(dt)
            broomY = broomPos.y
            if complete then
                if UpwardTween == true then
                    broomPos = {y = 200}
                    UpwardTween = false
                    broomStopped = false
                    broomTween = nil
                    complete = false
                    print('complete') 
                else
                    broomTween = tween.new(1, broomPos, {y = 200}, 'inQuad')
                    UpwardTween = true
                end
            end
        end
    end
end


function Minigame2:update(dt)
    if score == 4 then
        if chuteY == 0 then
            ParentMinigame:completeMinigame(2)
        else
            chuteY = chuteY + 100 * dt
        end
    end
    if broomX + broomSpriteWidth / 2 > handX and broomX + broomSpriteWidth / 2 < handX + handWidth and broomY < handY + handHeight and broomY + broomSpriteHeight > handY then
        handSpawned = false
        handRaised = false
        handY = screenHeight + handHeight
        score = score + 1
        broomPos.y = broomY
        broomTween = tween.new(1, broomPos, {y = 200}, 'inQuad')
        UpwardTween = true
        for _, particleData in ipairs(allParticleData) do
            particleData.system:start() -- Start emitting particles
            particleData.system:emit(particleData.emitAtStart)
        end
    end
    for _, particleData in ipairs(allParticleData) do
        particleData.system:update(dt)
        particleData.system:setPosition(broomX + broomSpriteWidth / 2, broomY + broomSpriteHeight * 2)
        end
    self:broomWiggle(dt)
    self:broomMove(dt)
    if not handRaised then
        self:raiseHand(dt)
    end
    if currenTime > 1 and not handSpawned then
        self:spawnHand()
        handSpawned = true
        currenTime = 0
    end
    currenTime = currenTime + dt
    Minigame2:updateImages()
    
    

    
end

function Minigame2:draw()
    love.graphics.draw(trashChute, 0, 0, 0, 2.5, 2.5)
    --love.graphics.draw(trashChute2, 0, 0 , 0, 2.5, 2.5)
    for _, particleData in ipairs(allParticleData) do
		love.graphics.draw(particleData.system)
	end
    love.graphics.draw(broomSprite, broomX, broomY, 0, 2, 2)
    if score == 0 then
        kiranLimbs:gotoFrame(2)
        kiranLimbs:draw(kiranLimb, handX, handY, 0, 3, 3)
    end
    if score == 1 then
        kiranLimbs:gotoFrame(1)
        kiranLimbs:draw(kiranLimb, handX, handY, 0, 3, 3)
    end
    if score == 2 then
        kiranLimbs:gotoFrame(4)
        kiranLimbs:draw(kiranLimb, handX, handY, 0, 3, 3)
    end
    if score == 3 then
        kiranLimbs:gotoFrame(3)
        kiranLimbs:draw(kiranLimb, handX, handY, 0, 3, 3)
    end
    love.graphics.print(broomX, 10, 10)
    love.graphics.print(handY, 20, 20)
    love.graphics.draw(trashChute3, 0, 0, 0, 2.5, 2.5)
    love.graphics.print("Controls:", 50, h - 200, 0, 0.5, 0.5)
    love.graphics.draw(currentImage2, 30, h - 150, 0, 2, 2)
    love.graphics.print("= HIT BODY", 150, h - 100, 0, 0.5, 0.5) 
    button:draw(buttonSprite, 95, 425, 0, 3, 3)
    love.graphics.draw(trashChute2, 0, chuteY, 0, 2.5, 2.5)


    

end


function Minigame2:mousepressed(x, y, button)
    if button == 1 then
        broomStopped = true
    end
end

function Minigame2:mousereleased(x, y, button)
    
end


return Minigame2
