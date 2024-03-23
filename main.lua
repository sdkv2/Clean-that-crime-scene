function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    screenWidth, screenHeight = love.window.getDesktopDimensions()
    local fullscreenMode = {fullscreen = true, fullscreentype = "exclusive"}
    love.window.setMode(screenWidth, screenHeight, fullscreenMode)
    w = love.graphics.getWidth()
    h = love.graphics.getHeight()
    
    rectangles = {}

    anim8 = require 'libraries/anim8'
    sti = require 'libraries/sti'
    camera = require 'libraries/camera'
    movePlayer = require 'movePlayer'
    class = require 'libraries/middleclass'
    wf = require 'libraries/windfield'

    players = require 'player'
    NPC = require 'npc'
    border = require("border")
    
    npcs = {}
    cam = camera()
    world = wf.newWorld(0, 0, true)

    zoom = 1.5
    gameMap = sti('maps/map2.lua')
    interact = love.graphics.newImage('sprites/interact.png')

    world:addCollisionClass('Interactive')
    world:addCollisionClass('Player')
    animation = {
        explosion ={ 
            start = {'1-6',1,'1-6',2,'1-6',3}
        },
        numbers = {
            start = {'1-3',1}
        }
    }
    inverted = false
    explosion = NPC:new(500, 500, 'explosion.png', 72, 100, 2, animation['explosion'], 'explosion')
    numbers = NPC:new(100, 100, 'Sprite-0001.png', 32, 48, 0, animation['numbers'], 'numbers')
    player = players:new()

    mapW = gameMap.width * gameMap.tilewidth
    mapH = gameMap.height * gameMap.tileheight

    print(mapW, mapH)

    panning = false
    

    walls = {}
    for _, obj in pairs(gameMap.layers['Colliders'].objects) do
        local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wall:setType('static')
        table.insert(walls, wall)
    end
    cam.x = player.x
    cam.y = player.y
    -- Initialization code goes here
end

function pan(cam, object, dt)
    cam:lockPosition(object.x, object.y, cam.smooth.linear(1000))
end

function camCheck(zoom)
    -- Check if the camera object is valid
    if cam then
        -- Get the current camera position
        local camX, camY = cam:position()

        -- Adjust the map dimensions based on the zoom level
        local adjustedMapW = mapW
        local adjustedMapH = mapH

        -- Calculate the minimum and maximum bounds for the camera
        local minX = w / 2 / zoom
        local minY = h / 2 / zoom 
        local maxX = adjustedMapW - w/(2 *zoom)
        local maxY = adjustedMapH - h/(2 *zoom ) 
        -- Clamp the camera position within the bounds
        cam.x = math.max(minX, math.min(maxX, camX))
        cam.y = math.max(minY, math.min(maxY, camY))
    end
end

function love.update(dt)
    require('libraries/lovebird').update()
    if chatting == true then
        rectangles, complete = border(dt, rectangles, targeted, inverted, true)
        if complete == true then
            chatting = false
        end
    end
    player.isMoving = false
    player.currentAnimation:update(dt)
    if panning == false then
        pan(cam, player, dt, 350)
    end
    camCheck(zoom)

    movePlayer(player, dt)

    x = player:update(dt)
    world:update(dt)
    player:moveCheck()

    if x[1] ~= nil then
        interactable = true
    else
        interactable = false
    end

    player.x = player.collider:getX()
    player.y = player.collider:getY() - 20

    for _, npc in pairs(npcs) do
        npc.x = npc.collider:getX() 
        npc.y = npc.collider:getY()
        npc.r = npc.collider:getAngle()
        npc.currentAnimation:update(dt)
    end

    player.isMoving = false


end
function love.keypressed(key)
    if key == "z" then
        if interactable == true then
            rectangles = {}
            inverted = false
            object = x[1]:getObject()
            chatting = true
            complete = false
            targeted = object
        end
    end
    if key == "x" then
            chatting = true
            complete = false
            inverted = true
            
    end
    if key == "j" then
        print (screenHeight)
    end
    
    if key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    cam:attach()
        cam:zoomTo(zoom)
        gameMap:drawLayer(gameMap.layers['Floor'])
        gameMap:drawLayer(gameMap.layers['Furniture'])    
        for _, npc in pairs(npcs) do
            npc:draw()
        end
        player:draw()
        world:draw()
        if interactable == true then
            love.graphics.draw(interact, player.x -20, player.y - 90, 0, 2, 2, 8, 8)
        end
    cam:detach()
    love.graphics.setColor(0,0,0)
    for _, rect in ipairs(rectangles) do
        love.graphics.rectangle('fill', rect.x, rect.y, rect.width, rect.height)
    end
    love.graphics.setColor(1,1,1)


end