-- npc.lua
local class = require 'libraries/middleclass'
local interactable = class('interactble')
function interactable:initialize(name, x, y, width, height, image, scale)
    self.x = x
    self.y = y
    if image then
        self.image = love.graphics.newImage(image)
        self.scale = scale or 1
    end
    self.width = width
    self.height = height
    self.collider = world:newRectangleCollider(self.x, self.y, self.width, self.height)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Interactive')
    self.collider:setType('static')
    self.collider:setObject(self)
    self.scale = 1
end

function interactable:destroy()
    self.collider:destroy()
end

function interactable:draw()
    if self.image then
        love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
    end
end

return interactable