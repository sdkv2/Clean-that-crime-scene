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
            start = {'1-6',1,'1-6',2,'1-3',3}
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

    gameMap:resize(love.graphics.getWidth() * 2, love.graphics.getHeight() * 2)
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
        local minX = w / 2 / zoom -- Adjust the minimum x bound
        local minY = h / 2 / zoom -- Adjust the minimum y bound
        local maxX = adjustedMapW - w/(2 *zoom)-- Adjust the maximum x bound
        local maxY = adjustedMapH - h/(2 *zoom ) -- Adjust the maximum y bound
        -- Clamp the camera position within the bounds
        cam.x = math.max(minX, math.min(maxX, camX))
        cam.y = math.max(minY, math.min(maxY, camY))
    end
end

function love.update(dt)
    if chatting == true then
        rectangles, complete = border(dt, rectangles, targeted, inverted)
        if complete == true then
            chatting = false
        end
    end
    require("libraries/lovebird").update()
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
    
    if key == "escape" then
        love.event.quit()
    end
end


function border(dt, rectangles, target, inverted)
    local invert = inverted or false
    local topRectHeight = rectangles and rectangles[1] and rectangles[1].height or 0
    local bottomRectHeight = rectangles and rectangles[2] and rectangles[2].height or 0
    local screenX, screenY = cam:cameraCoords(player.x, player.y)
    local targetX, targetY = cam:cameraCoords(target.x, target.y)
    local worldX, worldY = cam:cameraCoords(0, h)
    
    local lowerY = math.min(screenY - player.spriteHeight - 80 * zoom, targetY - target.height * zoom * target.scale * 0.5)
    local higherY = math.max(screenY + player.spriteHeight * zoom, targetY + target.height * zoom * target.scale * 0.5)
    
    if (screenHeight - higherY) < 300 then
        higherY = screenHeight - 300
    end
    if invert then
        newTopRectHeight = topRectHeight - math.abs(lowerY - topRectHeight) * dt * 3
        newBottomRectHeight = bottomRectHeight - math.abs(higherY - (h - bottomRectHeight)) * dt * 3
    else
        newTopRectHeight = topRectHeight + math.abs(lowerY - topRectHeight) * dt * 3
        newBottomRectHeight = bottomRectHeight + math.abs(higherY - (h - bottomRectHeight)) * dt * 3
    end
    local topComplete = false
    local bottomComplete = false
    local clear = false
    if invert then
        local minSize = 5
        local maxSize = h
        if newTopRectHeight < minSize and newBottomRectHeight < minSize then
            bottomComplete = true
            topComplete = true
            clear = true
            print("cleared")
            

        end
    else
        if newTopRectHeight > lowerY - 40  then
            newTopRectHeight = topRectHeight
            topComplete = true
        end
    
        if h - newBottomRectHeight < higherY + 40 then
            newBottomRectHeight = bottomRectHeight
            bottomComplete = true
        end
        
    end
    
    local rectangles = {
        {x = 0, y = 0, width = w, height = newTopRectHeight},
        {x = 0, y = h - newBottomRectHeight, width = w, height = newBottomRectHeight}
    }
    
    if clear == true then
        rectangles = {}
    end
    local complete = topComplete and bottomComplete
    return rectangles, complete
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