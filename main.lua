if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
chat = require("npcs.chat")
local loadzone = require("loadzone")
interactable = require 'interact'
local isInteractable
rectangleState = 'waiting'
fade = require 'fade'
-- Define game states
 PLAYING = 1
local CUTSCENE = 2
local TITLE = 3
-- Initialize game state
gameState = TITLE
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

local AvailableLoadZones = {}
local cutsceneLogic = require 'cutscene'
Kyle = require 'npcs/kyle'
local interact 

function love.load()
    
    local Explosion = require 'npcs/explosion'
    target = nil

    love.graphics.setDefaultFilter('nearest', 'nearest')
    interact = love.graphics.newImage('sprites/interact.png')
    screenWidth, screenHeight = love.window.getDesktopDimensions()
    local fullscreenMode = {fullscreen = false, fullscreentype = "desktop"}
    love.window.setMode(screenWidth, screenHeight, fullscreenMode)
    w = love.graphics.getWidth()
    h = love.graphics.getHeight()
    TitleWidth = (w - text:getWidth()) / 2
    TitleHeight = (h - text:getHeight()) / 2 + 200
    TitleText = love.graphics.newText(font, "Press Enter to start")
    love.graphics.setBackgroundColor(0,0,0)
    anim8 = require 'libraries/anim8'
    sti = require 'libraries/sti'
    camera = require 'libraries/camera'
    movePlayer = require 'movePlayer'
    class = require 'libraries/middleclass'
    wf = require 'libraries/windfield'
    local moonshine = require 'libraries/moonshine'

    effect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt)
    effect.crt.distortionFactor = {1.02, 1.04}
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

    loadNewMap('maps/mansionroom.lua', 300, 300)

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
    gameMap = sti(mapPath)

    for _, npc in pairs(npcs) do
        npc.collider:destroy()
    end
    npcs = {}
    
    for _, loadzone in pairs(AvailableLoadZones) do
        loadzone:destroy()
    end
    AvailableLoadZones = {}

    if mapPath == 'maps/mansionroom.lua' then
        kyle = Kyle:new(700, 800, 'kylesprite.png', 32, 48, animation['kyle'], 'kyle', 'kyleportrait.png')
        kiran = Kyle:new(3000, 3000, 'kylesprite.png', 32, 48, animation['kyle'], 'kiran', 'kiranportrait.png')        
            
    end
    if mapPath == 'maps/kitchen.lua' then
    end
    world:update(0) 
    for _, obj in pairs(gameMap.layers['Load'].objects) do
        local loadZone = loadzone:new(obj.name, obj.x, obj.y, obj.width, obj.height, 'maps/' .. obj.name .. '.lua', obj.properties.spawnX, obj.properties.spawnY)
        if loadZone then
            table.insert(AvailableLoadZones, loadZone)
        end
    end

    cam.x = player.collider:getX()
    cam.y = player.collider:getY()

    -- Delete old colliders
    for _, wall in ipairs(walls) do
        if wall:isDestroyed() == false then
            wall:destroy()
        end
    end
    walls = {}
    -- Load new map
    -- Add new colliders
    for _, obj in pairs(gameMap.layers['Colliders'].objects) do
        local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wall:setType('static')
        table.insert(walls, wall)
        if obj.name == 'Door' then
            Door = interactable:new('Door', obj.x, obj.y, obj.width, obj.height)

        end
        if obj.name == 'Door1' then
            Door1 = interactable:new('Door1', obj.x, obj.y, obj.width, obj.height)

        end
        if obj.name == 'Door2' then
            Door2 = interactable:new('Door2', obj.x, obj.y, obj.width, obj.height)

        end
        if obj.name == 'Door3' then
            Door3 = interactable:new('Door3', obj.x, obj.y, obj.width, obj.height)

        end
        if obj.name == 'Door4' then
            Door4 = interactable:new('Door4', obj.x, obj.y, obj.width, obj.height)

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

function updateAlphaValues(dt)
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
end


function love.update(dt)
    if gameState == TITLE then
        if love.keyboard.isDown("return") then
            gameState = CUTSCENE
            cutsceneLogic:init()
            complete = false
           
        end 
        updateAlphaValues(dt)
    else
        if gameState == CUTSCENE then
            pan(cam, cutsceneLogic.target, dt)
            cutsceneLogic:update(dt)
            
    else
        if minigame.currentMinigame ~= nil then
            minigame:update(dt)
            if not myTimer:isExpired() then myTimer:update(dt) end

        else
            if not myTimer:isExpired() then myTimer:update(dt) end
            player.isMoving = false
            player.currentAnimation:update(dt)

            

            -- If not interacting with an object, check for player movement
            if target == nil then
                player:moveCheck()
                love.graphics.setFont(love.graphics.newFont(12))

                movePlayer(player, dt)
            end
            pan(cam, player, dt)

            --Checks if the player is in the loadzone or if they are able to interact with an object
            player:update(dt)
            -- Ensure 'interactables' is not nil before performing operations
            if player.interactables ~= nil then
                if player.interactables[1] ~= nil then
                    isInteractable = true
                else
                    isInteractable = false
                end
            else
                print("Error: player.interactables is nil")
            end

            chat:update(dt)



            player.isMoving = false
        end
    end
    for _, npc in pairs(npcs) do
        npc.x = npc.collider:getX() 
        npc.y = npc.collider:getY()
        npc.r = npc.collider:getAngle()
        npc.currentAnimation:update(dt)
    end
    world:update(dt)
    camCheck(zoom)

    fade.handleFade(dt)
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
        if key == "l" then
            fade.isActive = true
            minigame:setMinigame(2)

        end
    end
    
    if key == "escape" then
        love.event.quit()
    end
end
end

function titleDraw()
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
    end
function love.draw()
    if gameState == TITLE then
        titleDraw()
        
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
                if gameState == CUTSCENE then
                    cutsceneLogic:draw()
                end
                cam:detach()
                myTimer:draw()
                chat:draw()
                love.graphics.print("Y=" ..player.y, 50, 400, 0, 4 ,4)
                love.graphics.print("X=" ..player.x, 50, 300, 0, 4, 4)
            end 
        end)
    fade.draw()
    cutsceneLogic:drawText()
    end
end


function love.mousereleased(x,y, button)
    if minigame.currentMinigame ~= nil then
        minigame:mousereleased(x, y, button)
    end
end