-- kyle.lua
local class = require 'libraries/middleclass'
local NPC = require 'npc'

Kyle = class('Kyle', NPC)

function Kyle:initialize(x, y, spriteSheet, spriteWidth, spriteHeight, animations, name, portraitSheet)
    NPC.initialize(self, x, y, spriteSheet, spriteWidth, spriteHeight, animations, name, portraitSheet)
end

function Kyle:interact()
    local dx = player.x - self.x
        local dy = player.y - self.y
        local spriteWidth, spriteHeight = self.currentAnimation:getDimensions()

        if math.abs(dx) > spriteWidth then
            if dx < 0 then
                self.currentAnimation = self.animations.leftidle
            else
                self.currentAnimation = self.animations.rightidle
            end
        elseif math.abs(dy) > spriteHeight then
            if dy < 0 then
                self.currentAnimation = self.animations.upidle
            else
                self.currentAnimation = self.animations.downidle
            end
        end
    if currentRoom == "maps/mansionroom.lua" then
        chat:chat(self.name, '6', function () self.currentAnimation = self.animations.downidle end)
    end
    if currentRoom == "maps/cctv.lua" then
        if cctvState == 1 then
            chat:chat(self.name, 'CCTV2', function () self.currentAnimation = self.animations.upidle end)
        else
            chat:chat(self.name, 'CCTV', function () self.currentAnimation = self.animations.downidle end)
        end
    end
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

function Kyle:destroy()
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end
return Kyle
