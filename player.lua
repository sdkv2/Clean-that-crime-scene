local anim8 = require 'libraries/anim8'
local class = require 'libraries/middleclass'

local player = class('player')

function player:initialize()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    self.speed = 500
    self.x = width / 2
    self.y = height / 2
    self.isPlayer = true
    self.scale = 3
    self.spriteSheet = love.graphics.newImage('sprites/player-sprite.png')
    self.grid = anim8.newGrid(17, 25, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {
        down = anim8.newAnimation(self.grid('1-2', 2), 0.1),
        up = anim8.newAnimation(self.grid('1-2', 1), 0.1),
        left = anim8.newAnimation(self.grid('3-4', 2), 0.1),
        right = anim8.newAnimation(self.grid('3-4', 1), 0.1)
    }
    self.currentAnimation = self.animations.down
    self.spriteWidth, self.spriteHeight = self.currentAnimation:getDimensions()

    self.collider = world:newBSGRectangleCollider(400, 250, 18*3, 15*3, 3)
    self.collider:setFixedRotation(true)
    self.renderAboveFurniture = false
end

function player:draw()
    return self.currentAnimation:draw(self.spriteSheet, self.x, self.y, nil, 2.5, nil, 8.5, 12.5)
end

function player:moveCheck()
    if self.isMoving == false then
        self.currentAnimation:gotoFrame(1)
    end
end
function player:update(dt)
    -- Query the based on direction
    if self.currentAnimation == self.animations.right then
        items = world:queryLine(self.x, self.y, self.x + 50, self.y - 15, {'Interactive'})

    elseif self.currentAnimation == self.animations.left then
        items = world:queryLine(self.x, self.y, self.x - 50, self.y, {'Interactive'})

    elseif self.currentAnimation == self.animations.up then
        items = world:queryLine(self.x, self.y, self.x, self.y - 75, {'Interactive'})

    elseif self.currentAnimation == self.animations.down then
        items = world:queryLine(self.x, self.y, self.x, self.y + 100, {'Interactive'})
    end

    return items
end

return player