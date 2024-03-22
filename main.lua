function love.load()
    anim8 = require 'libraries/anim8'
    sti = require 'libraries/sti'
    camera = require 'libraries/camera'
    movePlayer = require 'movePlayer'
    class = require 'libraries/middleclass'
    wf = require 'libraries/windfield'

    players = require 'player'
    NPC = require 'npc'

    cam = camera()
    world = wf.newWorld(0, 0, true)
    gameMap = sti('maps/map2.lua')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    animations = { 
        start = {'1-6',1,'1-6',2,'1-3',3},
    }
    
    explosion = NPC:new(500, 500, 'explosion.png', 72, 100, 2, animations)
    w = love.graphics.getWidth()
    h = love.graphics.getHeight()

    player = players:new()


    trueLocation = {}
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    mapW = gameMap.width * gameMap.tilewidth
    mapH = gameMap.height * gameMap.tileheight

    panning = false
    target = player

    NPCS = {guy, guy2, explosion}
    

    walls = {}
    for _, obj in pairs(gameMap.layers['Colliders'].objects) do
        local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wall:setType('static')
        table.insert(walls, wall)
    end

    -- Initialization code goes here
end




function pan(cam, object, dt)
    cam:lockPosition(object.x, object.y, cam.smooth.linear(750), mapW - w/2)
end

function camCheck(x, y)
    if x < w/2 then
        cam.x = w/2
    end
    if y < h/2 then
        cam.y = h/2
    end

    if x > mapW - w/2 then
        cam.x = mapW - w/2
    end
    if y > mapH - h/2 then
        cam.y = mapH - h/2
    end
end
function love.keypressed(key)
    if key == "k" then
        panning = true
        target = guy
    end
    if key == "b" then
        panning = true
        target = guy2
    end
    if key == "m" then
        panning = false
        target = player
    end
end

function love.update(dt)
    
    player.isMoving = false
    player.currentAnimation:update(dt)
    
    if panning == false then
        pan(cam, player, dt, 350)

    else
        pan(cam, target, dt, 350)

    end
    camCheck(cam.x, cam.y)
    world:update(dt)
    movePlayer(player, dt)
    player:moveCheck()


    player.x = player.collider:getX()
    player.y = player.collider:getY() - 20

    for _, npc in pairs(NPCS) do
        npc.x = npc.collider:getX() 
        npc.y = npc.collider:getY()
        npc.r = npc.collider:getAngle()
        npc.currentAnimation:update(dt)
    end

    player.isMoving = false

    
    

end
function love.draw()
    cam:zoomTo(1)
    cam:attach()
        gameMap:drawLayer(gameMap.layers['Tile Layer 1'])
        gameMap:drawLayer(gameMap.layers['Furniture'])    
        for _, npc in pairs(NPCS) do
            npc:draw()
        end
        player:draw()
        world:draw()
    cam:detach()
    

end