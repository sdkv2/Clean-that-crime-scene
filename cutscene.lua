-- cutscene.lua

-- Define the cutscene class
local cutscene = {}

-- Constructor
function cutscene:init()
    self.borderRect = {}
    self.complete = false
    chat:chat('kyle', '1')
    -- Initialize the cutscene here
end

-- Update method
function cutscene:update(dt)
    for _, npc in pairs(npcs) do
        npc.x = npc.collider:getX() 
        npc.y = npc.collider:getY()
        npc.r = npc.collider:getAngle()
        npc.currentAnimation:update(dt)
    end
    chat:update(dt)


    

    
    -- Update the cutscene logic here
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
end

-- Return the cutscene class
return cutscene