-- npc.lua
local class = require 'libraries/middleclass'

local NPC = class('NPC')
function NPC:initialize(x, y, spriteSheet, spriteWidth, spriteHeight, border, animations)
    self.x = x
    self.y = y
    self.scale = 2
    self.width = spriteWidth
    self.height = spriteHeight
    self.spriteSheet = love.graphics.newImage('sprites/' .. spriteSheet)
    self.grid = anim8.newGrid(spriteWidth, spriteHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    for animName, animFrames in pairs(animations) do
        self.animations[animName] = anim8.newAnimation(self.grid:getFrames(unpack(animFrames)), 0.1)
    end
    self.collider = world:newRectangleCollider(self.x - self.width / 2, self.y - self.height / 2, self.width * self.scale, self.height * self.scale)
    
    self.currentAnimation = self.animations['start']
end

function NPC:draw()
    return self.currentAnimation:draw(self.spriteSheet, self.x, self.y, self.r, self.scale, nil, self.width / 2, self.height / 2)
end

return NPC