-- loadzone.lua
local class = require 'libraries/middleclass'

local LoadZone = class('LoadZone')

function LoadZone:initialize(name, x, y, width, height, targetMap, spawnX, spawnY)
    self.name = name
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.targetMap = targetMap
    self.spawnX = spawnX
    self.spawnY = spawnY
    self.collider = world:newRectangleCollider(self.x, self.y, self.width, self.height)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('LoadZone')
    self.collider:setType('static')
    self.collider:setObject(self)
end

function LoadZone:trigger()
    fade = true
    -- Load the target map and set the player's position to the spawn location
    loadNewMap(self.targetMap)
    player.collider:setPosition(self.spawnX, self.spawnY)
end

return LoadZone