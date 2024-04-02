-- loadzone.lua
local class = require 'libraries/middleclass'

local LoadZone = class('LoadZone')
function LoadZone:new(name, x, y, width, height, targetMap, spawnX, spawnY)
    local instance = LoadZone:initialize(name, x, y, width, height, targetMap, spawnX, spawnY)
    return instance
end

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
    return self
end

function LoadZone:trigger()
    player.collider:setPosition(self.spawnX, self.spawnY)

    -- Load the target map and set the player's position to the spawn location
    loadNewMap(self.targetMap)
end

function LoadZone:destroy()
    self.collider:destroy()
end

return LoadZone