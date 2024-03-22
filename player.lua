local anim8 = require 'libraries/anim8'
local class = require 'libraries/middleclass'

local player = class('player')

function player:initialize()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    self.speed = 250
    self.x = width / 2
    self.y = height / 2
    self.isPlayer = true
    self.spriteSheet = love.graphics.newImage('sprites/player-sprite.png')
    self.grid = anim8.newGrid(17, 25, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {
        down = anim8.newAnimation(self.grid('1-2', 2), 0.1),
        up = anim8.newAnimation(self.grid('1-2', 1), 0.1),
        left = anim8.newAnimation(self.grid('3-4', 2), 0.1),
        right = anim8.newAnimation(self.grid('3-4', 1), 0.1)
    }
    self.currentAnimation = self.animations.down

    self.collider = world:newBSGRectangleCollider(400, 250, 18*3, 15*3, 3)
    self.collider:setFixedRotation(true)
end

function player:draw()
    return self.currentAnimation:draw(self.spriteSheet, self.x, self.y, nil, 3, nil, 8.5, 12.5)
end

function player:moveCheck()
    if self.isMoving == false then
        self.currentAnimation:gotoFrame(1)
    end
end

return player