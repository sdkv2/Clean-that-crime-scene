-- npc.lua
local class = require 'libraries/middleclass'
local interactable = class('interactble')
function interactable:initialize(name, x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.collider = world:newRectangleCollider(self.x, self.y, self.width, self.height)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Interactive')
    self.collider:setType('static')
    self.collider:setObject(self)
    self.scale = 1
end

return interactable