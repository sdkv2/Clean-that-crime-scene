-- minigame1.lua
local Minigame2 = {}
Minigame2.__index = Minigame2
love.graphics.setDefaultFilter("nearest", "nearest")
local broomSprite = love.graphics.newImage('sprites/Broom.png')
local broomSpriteWidth = broomSprite:getWidth()
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
local handWidth = handSprite:getWidth()
local handHeight = handSprite:getHeight()
local handRaised = false
local handSpawned = false
function Minigame2.new()
    screenWidth, screenHeight = love.graphics.getDimensions()
    rectWidth = screenWidth
    handY = screenHeight + handHeight
    local self = setmetatable({}, Minigame2)
    return self
end

function Minigame2:spawnHand()
    handX = love.math.random(screenWidth * 0.3, screenWidth * 0.6)
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
    broomR = broomR + 3 * math.pi * love.timer.getDelta()
    broomY = 200 + math.sin(broomR) * 5
end

function Minigame2:broomMove(dt)
    if Reverse then
        broomX = broomX - 400 * dt
    else
        broomX = broomX + 400 * dt
    end
    if broomX > screenWidth * 0.7 then
        Reverse = true
    elseif broomX < screenWidth * 0.2 then
        Reverse = false
    end
end

function Minigame2:update(dt)
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
    
end

function Minigame2:draw()
    love.graphics.draw(broomSprite, broomX, broomY, 0, 2, 2)
    love.graphics.print(broomX, 10, 10)
    love.graphics.print(handY, 20, 20)

    love.graphics.draw(handSprite, handX, handY, 0, 3, 3)
    love.graphics.rectangle('fill', 0, screenHeight - rectHeight, rectWidth, rectHeight)    
end

function Minigame2:mousepressed(x, y, button)

end

return Minigame2