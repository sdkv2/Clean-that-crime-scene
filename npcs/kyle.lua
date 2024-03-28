-- kyle.lua
local class = require 'libraries/middleclass'
local NPC = require 'npc'

Kyle = class('Kyle', NPC)

function Kyle:initialize(x, y, spriteSheet, spriteWidth, spriteHeight, animations, name, portraitSheet)
    print(portraitSheet)
    NPC.initialize(self, x, y, spriteSheet, spriteWidth, spriteHeight, animations, name, portraitSheet)
end

function Kyle:interact()
    self.currentAnimation = self.animations['up']
    print(self.x)
    chat:chat(self.name, '1')
end

return Kyle
