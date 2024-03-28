if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
chat = require("npcs.chat")
local loadzone = require("loadzone")
local interact = love.graphics.newImage('sprites/interact.png')
interactable = require 'interact'
local isInteractable
rectangleState = 'waiting'
fade = require 'fade'
gameState = "title"
local panning = false
zoom = 2
chatting = false
local Minigame = require 'minigame'
local minigame = Minigame.new()
local titleArt = love.graphics.newImage('sprites/guy.png')
local borderSize = 6
local alpha = 0
local increasing = true
local delay = 0
local delayMax = 0.1
local alphaValues = {0.1, 0.2, 0.4, 0.6, 0.8, 1}
local alphaIndex = 1
local font = love.graphics.newFont("MS_PAIN.ttf", 128) -- Change the size as needed

local text = love.graphics.newText(font, "Press Enter to start")



function love.load()
    
    local Explosion = require 'npcs/explosion'
    local Kyle = require 'npcs/kyle'
    target = nil

    love.graphics.setDefaultFilter('nearest', 'nearest')

    screenWidth, screenHeight = love.window.getDesktopDimensions()
    local fullscreenMode = {fullscreen = false, fullscreentype = "desktop"}
    love.window.setMode(screenWidth, screenHeight, fullscreenMode)
    w = love.graphics.getWidth()
    h = love.graphics.getHeight()
    TitleWidth = (w - text:getWidth()) / 2
    TitleHeight = (h - text:getHeight()) / 2 + 200
    TitleText = love.graphics.newText(font, "Press Enter to start")

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

    players = require 'player'
    NPC = require 'npc'
    border = require "border"
    Timer = require 'timer'
    
    npcs = {}
    walls = {}

    cam = camera()
    world = wf.newWorld(0, 0, true)

    gameMap = sti('maps/mansionroomtrial.lua')

    world:addCollisionClass('Interactive')
    world:addCollisionClass('Player')
    world:addCollisionClass('LoadZone', {ignores = {'Player'}})
    animation = {
        explosion = {
            overworld = {
                downidle = {'1-6',1,'1-6',2,'1-6',3}
            },
            portrait = {
                neutral = {'1-6',1,'1-6',2,'1-6',3}
            }
        },
        kyle = {
            overworld = {
                downidle = {1, 1},
                down = {1, 1, 2, 1, 1, 1, 3, 1},
                up = {4, 1, 5, 1, 4, 1, 6, 1},
                upidle = {4, 1},
                left = {12, 1, 10, 1, 12, 1, 11, 1},
                leftidle ={12, 1},
                right = {7, 1, 8, 1, 7, 1, 9, 1},
                rightidle = {7, 1}
            },
            portrait = {
                neutral = {'1-2',1}
            }
        }
    }
    
    player = players:new()

    mapW = gameMap.width * gameMap.tilewidth
    mapH = gameMap.height * gameMap.tileheight

    explode = Explosion:new(500, 500, 'explosion.png', 72, 100, animation['explosion'], 'explosion', 'explosion.png')
    kyle = Kyle:new(100, 100, 'kylesprite.png', 32, 48, animation['kyle'], 'kyle', 'kyleportrait.png')

    Load1 = loadzone:initialize('Kitchen', player.x, player.y - 150, 100, 100, 'maps/2.lua', 100, 100)
    loadNewMap('maps/mansionroomtrial.lua', 300, 300)

    cam.x = player.x
    cam.y = player.y
    -- Initialization code goes here
    myTimer = Timer.new(300, function() timerExpired = true end)


end

function map()
    gameMap:drawLayer(gameMap.layers['Floor'])
    gameMap:drawLayer(gameMap.layers['TopWall'])
    gameMap:drawLayer(gameMap.layers['Decor'])
    for _, npc in pairs(npcs) do
        npc:draw()
    end
    if player.renderAboveFurniture then
        player:draw()
        gameMap:drawLayer(gameMap.layers['Furniture'])
        gameMap:drawLayer(gameMap.layers['Furniture2'])
    else
        gameMap:drawLayer(gameMap.layers['Furniture'])
        gameMap:drawLayer(gameMap.layers['Furniture2'])
        player:draw()
    end
    gameMap:drawLayer(gameMap.layers['BotWall'])  
    gameMap:drawLayer(gameMap.layers['Borders'])  
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

function pan(cam, object, dt)
    cam:lockPosition(object.x, object.y, cam.smooth.linear(1000))
end

function love.mousepressed(x, y, button)
    minigame:mousepressed(x, y, button)
end

function loadNewMap(mapPath,x,y)
    fade.startFade()

    -- Delete old colliders
    for _, wall in ipairs(walls) do
        if wall:isDestroyed() == false then
            wall:destroy()
        end
    end
    walls = {}
    -- Load new map
    gameMap = sti(mapPath)
    -- Add new colliders
    for _, obj in pairs(gameMap.layers['Colliders'].objects) do
        local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wall:setType('static')
        table.insert(walls, wall)
        if obj.name == 'Door' then
            Door2 = interactable:new('Door', obj.x, obj.y, obj.width, obj.height)

        end
        
    end
    
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
    if gameState == "title" then
        if love.keyboard.isDown("return") then
            gameState = "game"
        end
        if increasing then
            delay = delay + dt * 2
            if delay >= delayMax then
                delay = 0
                alphaIndex = alphaIndex + 1
                if alphaIndex > #alphaValues then
                    alphaIndex = #alphaValues
                    increasing = false
                end
                alpha = alphaValues[alphaIndex]
            end
        else
            delay = delay + dt * 1.6
            if delay >= delayMax then
                delay = 0
                alphaIndex = alphaIndex - 1
                if alphaIndex < 1 then
                    alphaIndex = 1
                    increasing = true
                end
                alpha = alphaValues[alphaIndex]
            end
        end
    else
    fade.handleFade(dt)
    if minigame.currentMinigame ~= nil then
        minigame:update(dt)
        if not myTimer:isExpired() then myTimer:update(dt) end

    else
        if not myTimer:isExpired() then myTimer:update(dt) end
        player.isMoving = false
        player.currentAnimation:update(dt)

        if panning == false then
            pan(cam, player, dt)
        end
        chat:update(dt)
        world:update(dt)

        -- If not interacting with an object, check for player movement
        if target == nil then
            player:moveCheck()
            camCheck(zoom)
            movePlayer(player, dt)
        end

        --Checks if the player is in the loadzone or if they are able to interact with an object
        player:update(dt)
        if player.interactables[1] ~= nil then
            isInteractable = true
        else
            isInteractable = false
        end


        -- Update the NPCs
        for _, npc in pairs(npcs) do
            npc.x = npc.collider:getX() 
            npc.y = npc.collider:getY()
            npc.r = npc.collider:getAngle()
            npc.currentAnimation:update(dt)
        end

        player.isMoving = false
    end
end
function love.keypressed(key)
    --If chatting is true, the player can press z to move to the next line of text
    -- else if the player is able to interact with an object, they can press z to interact with the object
    if minigame.currentMinigame ~= nil then
        minigame:keypressed(key)
    else
        if key == "z" then
            if chat.chatting == true then
                chat:nextLine()
            elseif isInteractable == true then
                rectangles = {}
                object = player.interactables[1]:getObject()
                target = object
                object:interact()
            end
        end

        if key == "j" then
            fade.isActive = true
            minigame:setMinigame(1)

        end
    end
    
    if key == "escape" then
        love.event.quit()
    end
end
end

function love.draw()
    if gameState == "title" then
        love.graphics.draw(titleArt, 0, 0, 0, 2, 1)

        love.graphics.setColor(1, 1, 1, alpha)

        -- Draw the text with the current alpha
        love.graphics.setColor(0, 0, 0, alpha) -- Set the color to black with the current alpha
        for dx=-borderSize, borderSize do
            for dy=-borderSize, borderSize do
                love.graphics.draw(TitleText, TitleWidth + dx, TitleHeight + dy)
            end
        end

        love.graphics.setColor(1, 1, 1, alpha) -- Set the color to white with the current alpha
        love.graphics.draw(TitleText, TitleWidth, TitleHeight)
        love.graphics.setColor(1, 1, 1)

    else
        effect(function()   
            if minigame.currentMinigame ~= nil then
                minigame:draw()
                myTimer:draw()
            else 
                cam:attach()
                    cam:zoomTo(zoom)
                    map()
                    world:draw()
                    if isInteractable == true then
                        love.graphics.draw(interact, player.x -20, player.y - 90, 0, 2, 2, 8, 8)
                    end
                cam:detach()
                myTimer:draw()
                chat:draw()
            end
            fade.draw() -- Moved outside the if-else block
        end)
    end
end