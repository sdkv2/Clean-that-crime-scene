-- npc.lua
local class = require 'libraries/middleclass'
local interactable = class('interactable')

function interactable:initialize(name, x, y, width, height, image, scale, interactFunction)
    self.x = x
    self.y = y
    if image ~= nil then
        self.image = love.graphics.newImage(image)
    end
    if scale ~= nil then
        self.scale = scale
    else
        self.scale = 1
    end
    self.width = width
    self.height = height
    self.collider = world:newRectangleCollider(self.x, self.y, self.width * self.scale, self.height * self.scale)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Interactive')
    self.collider:setType('static')
    self.collider:setObject(self)
    self.interactFunction = interactFunction
end
function interactable:destroy()
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end
function interactable:draw()
    if self.image then
        love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
    end
end

function interactable:interact()
    if self.interactFunction then
        self.interactFunction()
    end
end

return interactable