local anim8 = require 'libraries/anim8'
local class = require 'libraries/middleclass'

local player = class('player')

function player:initialize()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    self.speed = 350
    self.x = width / 2
    self.y = height / 2
    self.isPlayer = true
    self.scale = 3
    self.spriteSheet = love.graphics.newImage('sprites/butlersprites.png')
    self.grid = anim8.newGrid(32, 48, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {
        downidle = anim8.newAnimation(self.grid(1, 1), 0.2),
        down = anim8.newAnimation(self.grid('2-3', 1), 0.2),
        up = anim8.newAnimation(self.grid('5-6', 1), 0.2),
        upidle = anim8.newAnimation(self.grid(4, 1), 0.2),
        left = anim8.newAnimation(self.grid('10-11', 1), 0.2),
        leftidle = anim8.newAnimation(self.grid(12, 1), 0.2),
        right = anim8.newAnimation(self.grid('8-9', 1), 0.2),
        rightidle = anim8.newAnimation(self.grid(7, 1), 0.2)
    }
    self.currentAnimation = self.animations.down
    self.spriteWidth, self.spriteHeight = self.currentAnimation:getDimensions()

    self.collider = world:newBSGRectangleCollider(400, 250, 15*3, 7*3, 3)
    self.collider:setFixedRotation(true)
    self.renderAboveFurniture = false
end

function player:draw()
    return self.currentAnimation:draw(self.spriteSheet, self.x, self.y, nil, 1.5, nil, 8.5, 12.5)
end

function player:moveCheck()
    if player.isMoving == false then
        if self.currentAnimation == self.animations.right then
            self.currentAnimation = self.animations.rightidle
        elseif self.currentAnimation == self.animations.left then
            self.currentAnimation = self.animations.leftidle
        elseif self.currentAnimation == self.animations.up then
            self.currentAnimation = self.animations.upidle
        elseif self.currentAnimation == self.animations.down then
            self.currentAnimation = self.animations.downidle
        end
    end
end
function player:update(dt)
    -- Query the based on direction
    if self.currentAnimation == self.animations.right or self.currentAnimation == self.animations.rightidle then
        items = world:queryLine(self.x, self.y, self.x + 50, self.y, {'Interactive'})
        if not self.isMoving and self.currentAnimation ~= self.animations.rightidle then
            self.currentAnimation = self.animations.rightidle
        end

    elseif self.currentAnimation == self.animations.left or self.currentAnimation == self.animations.leftidle then
        items = world:queryLine(self.x, self.y, self.x - 50, self.y, {'Interactive'})
        if not self.isMoving and self.currentAnimation ~= self.animations.leftidle then
            self.currentAnimation = self.animations.leftidle
        end

    elseif self.currentAnimation == self.animations.up or self.currentAnimation == self.animations.upidle then
        items = world:queryLine(self.x, self.y + 30, self.x, self.y - 30, {'Interactive'})
        if not self.isMoving and self.currentAnimation ~= self.animations.upidle then
            self.currentAnimation = self.animations.upidle
        end

    elseif self.currentAnimation == self.animations.down or self.currentAnimation == self.animations.downidle then
        items = world:queryLine(self.x, self.y - 30, self.x, self.y + 50, {'Interactive'})
        if not self.isMoving and self.currentAnimation ~= self.animations.downidle then
            self.currentAnimation = self.animations.downidle
        end
    end

    return items
end

return player