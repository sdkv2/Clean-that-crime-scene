-- minigame1.lua
local Minigame1 = {}
Minigame1.__index = Minigame1
local anim8 = require 'libraries/anim8'

function Minigame1.new()
    local self = setmetatable({}, Minigame1)
    self.bowlingball = love.graphics.newImage('sprites/bowling.png')
    self.bowlingballWidth = self.bowlingball:getWidth()
    self.bowlingballHeight = self.bowlingball:getHeight()
    self.bowlingballGrid = anim8.newGrid(240, 160, self.bowlingballWidth, self.bowlingballHeight)
    self.bowlingballAnimation = anim8.newAnimation(self.bowlingballGrid('1-35', 1), 0.1)
    -- Initialize any other properties here
    return self
end

function Minigame1:keypressed(key, minigame)
    -- Handle key press for Minigame1
    if key == 'space' then
        minigame:setMinigame(0)
    end
end

function Minigame1:update(dt)
    self.bowlingballAnimation:update(dt)
    -- Update logic for minigame 1
end

function Minigame1:draw()
    self.bowlingballAnimation:draw(self.bowlingball, 900, 300, 0, 3, 3, 0, 0)
    -- Draw logic for minigame 1
end

return Minigame1