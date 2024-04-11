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
local win = love.audio.newSource("sfx/win.wav", "static")
function Minigame3.new(Parent)
    ParentMinigame = Parent
    local self = setmetatable({}, Minigame3)
    self.stages = {
        {directions = {'up', 'down', 'left', 'right'}, durations = {0.5, 0.5, 0.5,0.5}}, -- Stage 1
        {directions = {'left', 'right'}, durations = {3, 4}}, -- Stage 2
        {directions = {'up', 'right'}, durations = {4, 5}}, -- Stage 3
        {directions = {'down', 'left'}, durations = {5, 6}}, -- Stage 4
    }
    self.currentStage = 1
    self.currentDirection = 1
    self.allowInput = false
    self.timer = 0
    self.sound = nil
    self.started = false

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
    self:processStages(dt)
end

function Minigame3:processStages(dt)
    if not self.allowInput then
        self.timer = self.timer + dt
        if self.currentDirection > #self.stages[self.currentStage].directions then
            if self.timer >= self.stages[self.currentStage].durations[#self.stages[self.currentStage].durations] then
                self.allowInput = true
                self.sound:stop()
                self.currentDirection = 1
            end
           
            return
        end
        local stage = self.stages[self.currentStage]
        if self.timer >= stage.durations[self.currentDirection] then
            
            print(stage.directions[self.currentDirection])
            if self.sound then
                self.sound:stop()
            end
            self.sound = self:generateSound(stage.directions[self.currentDirection])
            self.sound:play()
            self.timer = 0
            self.currentDirection = self.currentDirection + 1
        end
    end
end


function Minigame3:mousepressed(x, y, button)

end
-- Add this to each minigame class

function Minigame3:keypressed(key)
    if not self.allowInput then
        return
    end
    if sound then
        sound:stop()
    end
    if key == 'w' or key == 'up' then
        butler:gotoFrame(1)
        sound = Minigame3:generateSound('up')
        sound:play()
        playerDirection = 'up'
    elseif key == 'a' or key == 'left' then
        sound = Minigame3:generateSound('left')
        sound:play()
        butler:gotoFrame(4)
        playerDirection = 'left'
    elseif key == 's' or key == 'down' then
        playerDirection = 'down'
        sound = Minigame3:generateSound('down')
        sound:play()
        butler:gotoFrame(2)
    elseif key == 'd' or key == 'right' then
        playerDirection = 'right'
        sound = Minigame3:generateSound('right')
        sound:play()
        butler:gotoFrame(3)
    end
    if playerDirection == self.stages[self.currentStage].directions[self.currentDirection] then
        self.currentDirection = self.currentDirection + 1
        print('correct')
        win = love.audio.newSource("sfx/win.wav", "static")
        win:play()
    end

    
end

function Minigame3:draw()
    love.graphics.draw(background, 0, 0, 0, 2.5, 2.5)
    butler:draw(butlerSheet, w/2 - 600, h/2 - 260, 0 ,5 ,5)

end

function Minigame3:mousereleased(x,y,button)
end

return Minigame3