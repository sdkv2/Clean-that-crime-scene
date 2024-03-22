-- npc.lua
local class = require 'libraries/middleclass'

local NPC = class('NPC')
function NPC:initialize(x, y, img)
    self.x = x
    self.y = y
    self.scale = 3
    self.image = love.graphics.newImage('sprites/' .. img)
    self.width = self.image:getWidth() * 3
    self.height = self.image:getHeight() * 3
    self.collider = world:newRectangleCollider(self.x, self.y, self.width, self.height)
end

function NPC:draw()
    --return self.currentAnimation:draw(self.spriteSheet, self.x, self.y, nil, self.scale, nil, self.image.getWidth(),self.image.getHeight())
    return love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)

end

return NPC