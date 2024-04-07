--MiniGame class_commons
local Minigame = {}
Minigame.__index = Minigame

local Minigame1 = require 'minigame1'
local Minigame2 = require 'minigame2'
local Minigame3 = require 'minigame3'
local Minigame4 = require 'minigame4'


function Minigame.new()
    local self = setmetatable({}, Minigame)
    self.currentMinigame = nil
    self.completedMinigames = {} -- Table to store which minigames have been completed
    return self
end

function Minigame:setMinigame(minigameNumber, callback)
    self.minigameNumber = minigameNumber
    self.callback = callback or function() end 

    if minigameNumber == 1 then
        self.currentMinigame = Minigame1.new(self)
    elseif minigameNumber == 2 then
        self.currentMinigame = Minigame2.new(self)
    elseif minigameNumber == 3 then
        self.currentMinigame = Minigame3.new(self)
    elseif minigameNumber == 4 then
        self.currentMinigame = Minigame4.new(self)
    else

        self.currentMinigame = nil
    end
end

function Minigame:keypressed(key)
    if self.currentMinigame ~= nil then
        self.currentMinigame:keypressed(key)
    end
end

function Minigame:isComplete(minigameNumber)
    return self.completedMinigames[minigameNumber] == true
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

function Minigame:completeMinigame(minigameNumber)
    self.completedMinigames[minigameNumber] = true
    self.callback()  -- Execute the callback when the minigame is completed
end

function Minigame:mousereleased(x,y,button)
    self.currentMinigame:mousereleased(x,y,button)
end

function Minigame:draw()

    if self.currentMinigame == nil then
        love.graphics.print('No minigame selected', 10, 10)
    else
        self.currentMinigame:draw()
    end
end
return Minigame