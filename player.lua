--player.lua

local anim8 = require 'libraries/anim8'
local class = require 'libraries/middleclass'
local player = class('player')

function player:initialize()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    self.speed = 350
    self.x = 800
    self.y = 800
    self.isPlayer = true
    self.scale = 3
    self.spriteSheet = love.graphics.newImage('sprites/butlersprites.png')
    self.portraitSheet = love.graphics.newImage('sprites/butler-portrait.png')
    self.grid = anim8.newGrid(32, 48, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {
        downidle = anim8.newAnimation(self.grid(1, 1), 0.2),
        down = anim8.newAnimation(self.grid(1, 1, 2, 1, 1, 1, 3, 1), 0.2),
        up = anim8.newAnimation(self.grid(4, 1, 5, 1, 4, 1, 6, 1), 0.2),
        upidle = anim8.newAnimation(self.grid(4, 1), 0.2),
        left = anim8.newAnimation(self.grid(12, 1, 10, 1, 12, 1, 11, 1), 0.2),
        leftidle = anim8.newAnimation(self.grid(12, 1), 0.2),
        right = anim8.newAnimation(self.grid(7, 1, 8, 1, 7, 1, 9, 1), 0.2),
        rightidle = anim8.newAnimation(self.grid(7, 1), 0.2)
    }
    self.portraitGrid = anim8.newGrid(128, 128, self.portraitSheet:getWidth(), self.portraitSheet:getHeight())  
    self.portraitExpressions = {
        neutral = anim8.newAnimation(self.portraitGrid('1-2', 1), 0.1),
    }
    self.currentAnimation = self.animations.down
    self.portraitAnimation = self.portraitExpressions.neutral
    self.spriteWidth, self.spriteHeight = self.currentAnimation:getDimensions()

    self.collider = world:newBSGRectangleCollider(self.x, self.y, self.spriteWidth, self.spriteHeight/3, 4)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Player')
    self.renderAboveFurniture = false
    self.animationMap = {
        [self.animations.right] = {idle = self.animations.rightidle},
        [self.animations.left] = {idle = self.animations.leftidle},
        [self.animations.up] = {idle = self.animations.upidle},
        [self.animations.down] = {idle = self.animations.downidle},
    }
end


function player:draw()
    return self.currentAnimation:draw(self.spriteSheet, self.x, self.y, nil, 1.5, nil, self.spriteWidth/2, self.spriteHeight/2)
end

function player:moveCheck()
    if player.isMoving == false then
        local animation = self.animationMap[self.currentAnimation]
        if animation then
            self.currentAnimation = animation.idle
        end
    end
end

function player:update(dt)
    self.x = self.collider:getX()
    self.y = self.collider:getY() - 20
    if self.collider:enter('LoadZone') then
        local collision_data = self.collider:getEnterCollisionData('LoadZone')
        local load = collision_data.collider:getObject()
        load:trigger()
    end
    self.animationMap[self.animations.right].queryLine = {self.x, self.y, self.x + 50, self.y}
    self.animationMap[self.animations.left].queryLine = {self.x, self.y, self.x - 50, self.y}
    self.animationMap[self.animations.up].queryLine = {self.x, self.y + 30, self.x, self.y - 30}
    self.animationMap[self.animations.down].queryLine = {self.x, self.y - 30, self.x, self.y + 90}

    local animation = self.animationMap[self.currentAnimation]
    if animation then
        local queryLine = animation.queryLine
        items = world:queryLine(queryLine[1], queryLine[2], queryLine[3], queryLine[4], {'Interactive'})
        if not self.isMoving and self.currentAnimation ~= animation.idle then
            self.currentAnimation = animation.idle
        end
    end

    return items
end

return player