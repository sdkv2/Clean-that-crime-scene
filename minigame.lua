local Minigame = {}
Minigame.__index = Minigame

local Minigame1 = require 'minigame1'
local Minigame2 = require 'minigame2'
local Minigame3 = require 'minigame3'


function Minigame.new()
    local self = setmetatable({}, Minigame)
    self.currentMinigame = nil
    self.completedMinigames = {} -- Add this line
    return self
end

function Minigame:setMinigame(minigameNumber)
    self.minigameNumber = minigameNumber
    if minigameNumber == 1 then
        self.currentMinigame = Minigame1.new(self)
    elseif minigameNumber == 2 then
        self.currentMinigame = Minigame2.new(self)
    elseif minigameNumber == 3 then
        self.currentMinigame = Minigame3.new(self)
    else
        self.currentMinigame = nil
    end
end

function Minigame:keypressed(key)
    if self.currentMinigame ~= nil then
        self.currentMinigame:keypressed(key)
    end
end

function Minigame:update(dt)
    if self.currentMinigame ~= nil then
        self.currentMinigame:update(dt)
    end
end

function Minigame:mousepressed(x, y, button)
    if self.currentMinigame ~= nil then
        self.currentMinigame:mousepressed(x, y, button)
    end
end
-- Add this method
function Minigame:completeMinigame(minigameNumber)
    self.completedMinigames[minigameNumber] = true
end

function Minigame:draw()

    if self.currentMinigame == nil then
        love.graphics.print('No minigame selected', 10, 10)
    else
        self.currentMinigame:draw()
    end
end
return Minigame