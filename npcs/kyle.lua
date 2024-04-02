-- kyle.lua
local class = require 'libraries/middleclass'
local NPC = require 'npc'

Kyle = class('Kyle', NPC)

function Kyle:initialize(x, y, spriteSheet, spriteWidth, spriteHeight, animations, name, portraitSheet)
    NPC.initialize(self, x, y, spriteSheet, spriteWidth, spriteHeight, animations, name, portraitSheet)
end

function Kyle:interact()
    self.currentAnimation = self.animations['up']
    chat:chat(self.name, '1')
end

function Kyle:setX(x)
    self.x = x
    if self.collider then  -- If the NPC has a collider
        self.collider:setX(x)  -- Update the position of the collider
    end
end

function Kyle:setY(y)
    self.y = y
    if self.collider then  -- If the NPC has a collider
        self.collider:setY(y)  -- Update the position of the collider
    end
end

function Kyle:draw()
    return self.currentAnimation:draw(self.spriteSheet, self.x, self.y, self.r, self.scale, nil, self.width / 2, self.height / 2)
end

return Kyle
