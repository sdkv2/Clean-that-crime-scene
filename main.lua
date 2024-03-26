if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
chat = require("npcs.chat")
local interact = love.graphics.newImage('sprites/interact.png')
function love.load()
    target = nil

    love.graphics.setDefaultFilter('nearest', 'nearest')

    screenWidth, screenHeight = love.window.getDesktopDimensions()
    local fullscreenMode = {fullscreen = false, fullscreentype = "desktop"}
    love.window.setMode(screenWidth, screenHeight, fullscreenMode)
    w = love.graphics.getWidth()
    h = love.graphics.getHeight()

    coolfont = love.graphics.newFont('MS_PAIN.ttf', 100)
    rectangles = {}
    love.graphics.setBackgroundColor(0,0,0)
    anim8 = require 'libraries/anim8'
    sti = require 'libraries/sti'
    camera = require 'libraries/camera'
    movePlayer = require 'movePlayer'
    class = require 'libraries/middleclass'
    wf = require 'libraries/windfield'
    local moonshine = require 'libraries/moonshine'
    effect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt)
    effect.scanlines.opacity = 0.1
    effect.scanlines.phase = 1
    effect.scanlines.thickness = 1
    effect.scanlines.width = 0.2

    chatting = false
    players = require 'player'
    NPC = require 'npc'
    border = require "border"
    timer = require 'timer'
    interactable = require 'interact'

    timerExpired = false
    npcs = {}
    cam = camera()
    world = wf.newWorld(0, 0, true)

    zoom = 2
    gameMap = sti('maps/mansionroomtrial.lua')

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

    panning = false
    local furnitureLayer = gameMap:addCustomLayer("FurnitureLayer", 4)
    tile = gameMap:getTileProperties('Furniture',18,19)
    


    walls = {}
    for _, obj in pairs(gameMap.layers['Colliders'].objects) do
        local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wall:setType('static')
        table.insert(walls, wall)
    end
    for _, obj in pairs(gameMap.layers['Colliders'].objects) do
        if obj.name == 'Door' then
            Door = interactable:new('Door', obj.x, obj.y, obj.width, obj.height)

        end
    end
    cam.x = player.x
    cam.y = player.y
    -- Initialization code goes here
    myTimer = timer(300,  function() timerExpired = true end)


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


    
    if not myTimer.isExpired() then myTimer.update(dt) end
    player.isMoving = false
    player.currentAnimation:update(dt)
    if panning == false then
        pan(cam, player, dt, 350)
    end
    chat:update(dt)
    world:update(dt)
    if target == nil then
        player:moveCheck()
        camCheck(zoom)
        movePlayer(player, dt)
    end
    x = player:update(dt)

    if x[1] ~= nil then
        interactable = true
    else
        interactable = false
    end

    player.x = player.collider:getX() - 13
    player.y = player.collider:getY() - 40

    for _, npc in pairs(npcs) do
        npc.x = npc.collider:getX() 
        npc.y = npc.collider:getY()
        npc.r = npc.collider:getAngle()
        npc.currentAnimation:update(dt)
    end

    player.isMoving = false
    local swapLayer = gameMap.layers['Swap']
    for _, object in ipairs(swapLayer.objects) do
        if player.x < object.x + object.width and player.x + player.spriteWidth > object.x and player.y < object.y + object.height and player.y + player.spriteHeight > object.y then
            player.renderAboveFurniture = true
            break
        else
            player.renderAboveFurniture = false
        end
    end
end
function love.keypressed(key)
    if key == "z" then
        if chatting == true then
            chatting = true
            chat:nextLine()
        elseif interactable == true then
            rectangles = {}
            object = x[1]:getObject()
            target = object
            object:interact()
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
    effect(function()    
    cam:attach()
        cam:zoomTo(zoom)
        gameMap:drawLayer(gameMap.layers['Floor'])
        gameMap:drawLayer(gameMap.layers['TopWall'])
        gameMap:drawLayer(gameMap.layers['Decor'])
        for _, npc in pairs(npcs) do
            npc:draw()
        end
        if player.renderAboveFurniture then
            player:draw()
            gameMap:drawLayer(gameMap.layers['Furniture'])
        else
            gameMap:drawLayer(gameMap.layers['Furniture'])
            player:draw()
        end
        gameMap:drawLayer(gameMap.layers['BotWall'])  
        gameMap:drawLayer(gameMap.layers['Borders'])  
        world:draw()
        if interactable == true then
            love.graphics.draw(interact, player.x -20, player.y - 90, 0, 2, 2, 8, 8)
        end
        if player.currentAnimation == player.animations.right then
            love.graphics.line(player.x, player.y, player.x + 50, player.y)
    
        elseif player.currentAnimation == player.animations.left then
            love.graphics.line(player.x, player.y, player.x - 50, player.y)
    
        elseif player.currentAnimation == player.animations.up then
            love.graphics.line(player.x, player.y + 30, player.x, player.y - 30)
    
        elseif player.currentAnimation == player.animations.down then
            love.graphics.line(player.x, player.y - 15, player.x, player.y + 50)
        end
    cam:detach()
    if timerExpired == true then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print('Timer Expired', 100, 100)
    else
        local timeRemain = myTimer.getCurrentTime()
        
        love.graphics.setColor(0, 0, 0, 0.6)
        
        love.graphics.rectangle('fill', 100, 100, 200, 100, 100, 100, 15)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print(timeRemain, coolfont, 110, 80, 0, 1, 1)


    end
    chat:draw()  

    end)
    
    love.graphics.setColor(0,0,0)
    
    love.graphics.setColor(1,1,1)



end