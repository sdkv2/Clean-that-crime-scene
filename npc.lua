-- npc.lua
local class = require 'libraries/middleclass'
local NPC = class('NPC')


function NPC:initialize(x, y, spriteSheet, spriteWidth, spriteHeight, animations, name, portraitSheet)
    self.x = x
    self.y = y
    self.scale = 1
    self.width = spriteWidth
    self.height = spriteHeight
    self.name = name
    self.spriteSheet = love.graphics.newImage('sprites/' .. spriteSheet)
    self.grid = anim8.newGrid(spriteWidth, spriteHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    for animType, animData in pairs(animations) do
        if animType == 'overworld' then
            for animName, animFrames in pairs(animData) do
                self.animations[animName] = anim8.newAnimation(self.grid:getFrames(unpack(animFrames)), 0.1)
            end
        end
    end
    self.collider = world:newRectangleCollider(self.x - self.width / 2, self.y - self.height / 2, self.width * self.scale, self.height * self.scale)
    self.currentAnimation = self.animations['downidle']
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Interactive')
    self.collider:setType('static')
    self.collider:setObject(self)
    print(portraitSheet)
    if portraitSheet then
        self.portraitExpressions = {}
        self.portraitSheet = love.graphics.newImage('sprites/' .. portraitSheet)
        self.portraitGrid = anim8.newGrid(128, 128, self.portraitSheet:getWidth(), self.portraitSheet:getHeight())  
        self.portraitExpressions = {
            neutral = anim8.newAnimation(self.portraitGrid('1-2', 1), 0.1),
        }
        self.portraitAnimation = self.portraitExpressions.neutral
    end
    table.insert(npcs, self)
end

function NPC:draw()
    return self.currentAnimation:draw(self.spriteSheet, self.x, self.y, self.r, self.scale, nil, self.width / 2, self.height / 2)
end

function NPC:interact()
end

return NPC