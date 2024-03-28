-- minigame3.lua
local Minigame3 = {}
Minigame3.__index = Minigame3

function Minigame3.new()
    local self = setmetatable({}, Minigame3)
    -- Initialize any other properties here
    return self
end

function Minigame3:update(dt)
    -- Update logic for minigame 3
end
-- Add this to each minigame class
function Minigame3:keypressed(key)
    -- Handle key press for Minigame1
end
function Minigame3:draw()
    -- Draw logic for minigame 3
end

return Minigame3