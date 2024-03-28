local Minigame = {}
Minigame.__index = Minigame

local Minigame1 = require 'minigame1'
local Minigame2 = require 'minigame2'
local Minigame3 = require 'minigame3'

function Minigame.new()
    local self = setmetatable({}, Minigame)
    self.currentMinigame = nil
    return self
end

function Minigame:setMinigame(minigameNumber)
    self.minigameNumber = minigameNumber
    if minigameNumber == 1 then
        self.currentMinigame = Minigame1.new()
    elseif minigameNumber == 2 then
        self.currentMinigame = Minigame2.new()
    elseif minigameNumber == 3 then
        self.currentMinigame = Minigame3.new()
    else
        self.currentMinigame = nil
    end
end

function Minigame:keypressed(key)
    if self.currentMinigame ~= nil then
        self.currentMinigame:keypressed(key, self)
    end
end

function Minigame:update(dt)
    if self.currentMinigame ~= nil then
        self.currentMinigame:update(dt)
    end
end

function Minigame:draw()

    if self.currentMinigame == nil then
        love.graphics.print('No minigame selected', 10, 10)
    else
        love.graphics.print('Minigame ' .. self.minigameNumber, 10, 10)
        self.currentMinigame:draw()
    end
end
return Minigame