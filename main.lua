if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end
chat = require("npcs.chat")
local loadzone = require("loadzone")
interactable = require 'interact'
local isInteractable
rectangleState = 'waiting'
fade = require 'fade'
local broomGet = false
-- Define game states
 PLAYING = 1
local CUTSCENE = 2
local TITLE = 3
-- Initialize game state
local chuteState = nil
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
currentRoom = nil
local font = love.graphics.newFont("MS_PAIN.ttf", 128) -- Change the size as needed
local text = love.graphics.newText(font, "Press Enter to start")
local interactables = {}
local AvailableLoadZones = {}
local cutsceneLogic = require 'cutscene'
Kyle = require 'npcs/kyle'
local interact 
local kiranDraw = true
local spongeGet = false
local bowlingballClean = false
function love.load()
    gameState = TITLE
    zoom = 2
    chatting = false
    cctvState = 0
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
    gameMap = sti("maps/mansionroom.lua")
    cam = camera()
    world = wf.newWorld(0, 0, true)

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

    loadNewMap('maps/mansionroom.lua')

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
    for _, interactable in pairs(interactables) do
        interactable:draw()
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

function broomInteract()
    if broomGet == false then
        chat:chat('Broom', '1', function () broomGet = true end)
    else
        chat:chat('Broom', '2')
    end
end

function love.mousepressed(x, y, button)
    minigame:mousepressed(x, y, button)
end

function kiranDestroy()
    kiranDraw = false
    for i, interactable in pairs(interactables) do
        if interactable.name == 'kiran' then
            interactable:destroy()
            table.remove(interactables, i)
        end
        if player.interactables then
            player.interactables[1] = nil
        end    
    end
end

function spongeDestroy()
    spongeGet = true
    for i, interactable in pairs(interactables) do
        if interactable.name == 'sponge' then
            interactable:destroy()
            table.remove(interactables, i)
        end
        if player.interactables then
            player.interactables[1] = nil
        end    
    end
    
end

function loadNewMap(mapPath,x,y)
    isInteractable = false
    player.interactables = nil
    target = nil
    fade.fadeAmount = 1
    fade.startFade()
    gameMap = sti(mapPath)
    if x and y then
        player.collider:setPosition(x, y)
    end
    for _, npc in pairs(npcs) do
        npc:destroy()
    end
    for _, interactable in pairs(interactables) do
        interactable:destroy()
    end
    npcs = {}
    interactables = {}
    for _, loadzone in pairs(AvailableLoadZones) do
        loadzone:destroy()
    end
    AvailableLoadZones = {}
    mapPath = string.lower(mapPath)
    currentRoom = mapPath

    if mapPath == 'maps/mansionroom.lua' then
        print(cutsceneLogic.cutsceneFinished)
        if cutsceneLogic.cutsceneFinished then
            print("cutscene finished")
            kyle = Kyle:new(1016, 763, 'kylesprite.png', 32, 48, animation['kyle'], 'kyle', 'kyleportrait.png')
            kyle.currentAnimation = kyle.animations.leftidle
            kyle.collider:setType("static")

            local kiran = interactable:new('kiran', 940, 762, 48, 32, "sprites/kirandead.png", 1.25, function() 
                target = kiran
                chat:chat('Kiran', '1', function () kiranDestroy() end) 
            end)
            
            bowlingball = interactable:new('bowlingball', 930, 835, 32, 32, "sprites/bloodybowlingball.png", 1, 
            function() 
                if bowlingballClean then
                    chat:chat('BowlingBall', '3')
                elseif spongeGet == false then 
                    chat:chat('BowlingBall', '1') 
                else
                    bowlingball:updateImages("sprites/singlebowling.png")
                    minigame:setMinigame(1, 
                    function() chat:chat('BowlingBall', '2') 
                    end)                 
                    bowlingballClean = true

                end
            end)
            if bowlingballClean then
                bowlingball:updateImages("sprites/singlebowling.png")
            end
            
            if kiranDraw then
                table.insert(interactables, kiran)
            else
                kiran:destroy()
            end
            table.insert(npcs, kyle)
            table.insert(interactables, bowlingball)
            for _, obj in pairs(gameMap.layers['Colliders'].objects) do
                if obj.name == 'Door' then
                    local obj = interactable:new(obj.name, obj.x, obj.y, obj.width, obj.height, nil, nil, function() chat:chat('Door', '1') end)
                    table.insert(interactables, obj)
                end
                if obj.name == 'Door2' then
                    local obj = interactable:new(obj.name, obj.x, obj.y, obj.width, obj.height, nil, nil, function() loadNewMap("maps/cctv.lua", 953, 620)  end)
                    table.insert(interactables, obj)
                end
            end

        else 
            kyle = Kyle:new(700, 800, 'kylesprite.png', 32, 48, animation['kyle'], 'kyle', 'kyleportrait.png')
            kiran = Kyle:new(3000, 3000, 'kylesprite.png', 32, 48, animation['kyle'], 'kiran', 'kiranportrait.png')
               
        end

    end
    if mapPath == 'maps/closet.lua' then
        for _, obj in pairs(gameMap.layers['Colliders'].objects) do
            if obj.name == 'Broom' then
                local obj = interactable:new(obj.name, obj.x, obj.y, obj.width, obj.height, nil, nil, function() broomInteract() end)
                table.insert(interactables, obj)
            end
        end
            
        
    end
    if mapPath == 'maps/cctv.lua' then
        kyle = Kyle:new(1124, 489, 'kylesprite.png', 32, 48, animation['kyle'], 'kyle', 'kyleportrait.png')
        table.insert(npcs, kyle)

        kyle.collider:setType("static")
        kyle.currentAnimation = kyle.animations.leftidle
        for _, obj in pairs(gameMap.layers['Colliders'].objects) do
            if obj.name == 'PC' then
                local obj = interactable:new(obj.name, obj.x, obj.y, obj.width, obj.height, nil, nil, function()  
                    if minigame:isComplete(2) and minigame:isComplete(1) then
                        if not minigame:isComplete(4) then 
                            fade.isActive = true
                            minigame:setMinigame(4, 
                            function() chat:chat('PC', '1') 
                            end) 
                        else 
                            chat:chat('PC', '2') 
                        end
                    else
                        chat:chat('PC', '3') 
                    end
                end
                )                table.insert(interactables, obj)
            end
        end
            

    end
    if mapPath == 'maps/kitchen.lua' then
        local sponge = interactable:new('sponge', 982, 292, 32, 32, "sprites/sponge.png", 1, function() chat:chat('Sponge', '1', function () spongeDestroy() end) end)
        for _, obj in pairs(gameMap.layers['Colliders'].objects) do
            if obj.name == 'Chute' then
                local obj = interactable:new(obj.name, obj.x, obj.y, obj.width, obj.height, nil, nil, function()
                    if minigame:isComplete(2) then 
                        chat:chat("Chute", "3") 
                    elseif kiranDraw == false then 
                        if broomGet and chuteState == 1 then
                            chat:chat("Chute", "7", function ()
                                fade.isActive = true
                                minigame:setMinigame(2, function() chat:chat("Chute", "2") end) 
                            end )  

                        elseif broomGet then 
                                chat:chat("Chute", "6", function ()
                                    fade.isActive = true
                                    minigame:setMinigame(2, function() chat:chat("Chute", "2") end) 
                                end )  

                        elseif chuteState == 1 then
                            chat:chat("Chute", "5")  
                        elseif broomGet ==false then 
                            chat:chat("Chute", "4") 
                            chuteState = 1
                        end
                    else 
                        chat:chat('Chute', "1")  
                    end 
                end)                
                table.insert(interactables, obj)
            end
        end
        if spongeGet == false then
            table.insert(interactables, sponge)
        else
            sponge:destroy()
        end
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

    for _, wall in ipairs(walls) do
        if wall:isDestroyed() == false then
            wall:destroy()
        end
    end
    walls = {}

    for _, obj in pairs(gameMap.layers['Colliders'].objects) do
        local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wall:setType('static')
        table.insert(walls, wall)   
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
            if target == nil then
                player:moveCheck()
                movePlayer(player, dt)
            end
            pan(cam, player, dt)

            player:update(dt)
            if player.interactables ~= nil then
                if player.interactables[1] ~= nil then
                    isInteractable = true
                else
                    isInteractable = false
                end
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
            minigame:setMinigame(4)

        end
        if key == "x" then
            chat:endChat()
            cutsceneLogic.cutsceneFinished = true
            gameState = PLAYING
            loadNewMap("maps/mansionroom.lua", 923, 760)

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
        love.graphics.setColor(0, 0, 0, alpha) 
        for dx=-borderSize, borderSize do
            for dy=-borderSize, borderSize do
                love.graphics.draw(TitleText, TitleWidth + dx, TitleHeight + dy)
            end
        end

        love.graphics.setColor(1, 1, 1, alpha) 
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
                --love.graphics.print("Y=" ..player.y, 50, 400, 0, 4 ,4)
                --love.graphics.print("X=" ..player.x, 50, 300, 0, 4, 4)
            end 
        end)
    fade.draw()
    if gameState == CUTSCENE then
    cutsceneLogic:drawText()
    end
    end

end


function love.mousereleased(x,y, button)
    if minigame.currentMinigame ~= nil then
        minigame:mousereleased(x, y, button)
    end
end