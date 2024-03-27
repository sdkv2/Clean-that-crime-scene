-- explosion.lua
local class = require 'libraries/middleclass'
local NPC = require 'npc'

Explosion = class('Explosion', NPC)

function Explosion:initialize(x, y, spriteSheet, spriteWidth, spriteHeight, animations, name, portraitSheet)
    print(portraitSheet)
    NPC.initialize(self, x, y, spriteSheet, spriteWidth, spriteHeight, animations, name, portraitSheet)
end

function Explosion:interact()
    print(self.x)
    chat:chat('explosion', '2')
end


return Explosion