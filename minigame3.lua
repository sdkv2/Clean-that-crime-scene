-- minigame3.lua
local Minigame3 = {}
Minigame3.__index = Minigame3
local anim8 = require 'libraries/anim8'
local butlerSheet = love.graphics.newImage('sprites/ddrbutler.png')
local g = anim8.newGrid(128, 160, butlerSheet:getWidth(), butlerSheet:getHeight())
local butler = anim8.newAnimation(g('1-4', 1), 0.1)
local background = love.graphics.newImage('sprites/blurredbackground.png')
local sound -- Define the sound variable outside the function
local upSound = love.audio.newSource('sfx/up.wav', 'static')
local downSound = love.audio.newSource('sfx/down.wav', 'static')
local leftSound = love.audio.newSource('sfx/left.wav', 'static')
local rightSound = love.audio.newSource('sfx/right.wav', 'static')
local sound = nil
function Minigame3.new(Parent)
    ParentMinigame = Parent
    local self = setmetatable({}, Minigame3)
    -- Initialize any other properties here
    return self
end
function Minigame3:generateSound(direction)
    if direction == 'up' then
        return upSound
    end
    if direction == 'down' then
        return downSound
    end
    if direction == 'left' then
        return leftSound
    end
    if direction == 'right' then
        return rightSound
    end
    
end
function Minigame3:update(dt)
    if not love.keyboard.isDown('w', 'up', 'a', 'left', 's', 'down', 'd', 'right') and sound then
        sound:stop()
        end
end

function Minigame3:mousepressed(x, y, button)

end
-- Add this to each minigame class

function Minigame3:keypressed(key)
    if sound then
        sound:stop()
    end
    if key == 'w' or key == 'up' then
        butler:gotoFrame(1)
        sound = Minigame3:generateSound('up')
        sound:play()
    elseif key == 'a' or key == 'left' then
        sound = Minigame3:generateSound('left')
        sound:play()
        butler:gotoFrame(4)
    elseif key == 's' or key == 'down' then
        
        sound = Minigame3:generateSound('down')
        sound:play()
        butler:gotoFrame(2)
    elseif key == 'd' or key == 'right' then

        sound = Minigame3:generateSound('right')
        sound:play()

        butler:gotoFrame(3)
    end
end

function Minigame3:draw()
    love.graphics.draw(background, 0, 0, 0, 2.5, 2.5)
    butler:draw(butlerSheet, w/2 - 600, h/2 - 260, 0 ,5 ,5)

end

function Minigame3:mousereleased(x,y,button)
end

return Minigame3