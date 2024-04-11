-- minigame4.lua
local Minigame4 = {}
Minigame4.__index = Minigame4
local anim8 = require 'libraries/anim8'
local loadingScreen = love.graphics.newImage('sprites/cctvload.png')
local g = anim8.newGrid(480, 270, loadingScreen:getWidth(), loadingScreen:getHeight())
local loadingComplete = false
local function loadingStatus()
    loadingComplete = true

end
local startup = love.audio.newSource("sfx/startup.wav", "static")
local passwordFail = love.graphics.newImage('sprites/passwordfail.png')
local loading = anim8.newAnimation(g('1-11', 1), 0.2, loadingStatus)
local drawGavin = false
local login = love.graphics.newImage('sprites/cctvlogin.png')
local keyArray = {}
local passwordFailActive
local timer
local gavin = love.graphics.newImage('sprites/gav.png')
local deleteScreen = love.graphics.newImage('sprites/cctvdelete.png')
local gDelete = anim8.newGrid(480, 270, deleteScreen:getWidth(), deleteScreen:getHeight())
local deleteComplete = false
local function deleteStatus()
    deleteComplete = true
end
local deleting = anim8.newAnimation(gDelete('1-23', 1), 0.2, deleteStatus)
function Minigame4.new(Parent)
    love.audio.play(startup)
    timer = 0
    passwordFailActive = false
    keyArray = {}
    loadingComplete = false
    love.graphics.setFont(love.graphics.newFont('MS_PAIN.ttf', 72))
    ParentMinigame = Parent
    local self = setmetatable({}, Minigame4)
    self.isDeleting = false

    -- Initialize any other properties here
    return self
end

function Minigame4:update(dt)
    loading:update(dt)
    if self.isDeleting then
        deleting:update(dt)
    
    elseif love.keyboard.isDown("backspace") then
        timer = timer + dt
        if timer >= 0.1 then
            timer = 0
            table.remove(keyArray, #keyArray)
        end
end
    -- Update logic for minigame 4
end

function Minigame4:mousepressed(x, y, button)
    -- Check if the mouse click is within the rectangle
    if loadingComplete then
        if x >= 1552 and x <= 1552 + 332 and y >= 900 and y <= 900 + 104 then
            ParentMinigame:setMinigame(nil)
            fade.isActive = true
            target = nil
        end
    end
end
function Minigame4:keypressed(key)
    if loadingComplete then
        local keypressed = love.audio.newSource("sfx/keydown.wav", "static")
        love.audio.play(keypressed)
        if key == 'return' then
            local keyString = table.concat(keyArray)
            print(keyString)
            if keyString == 'password1' then
                self.isDeleting = true
            elseif keyString == 'gavin' then
                drawGavin = true
            elseif keyString == 'computer' and cctvState == 0 then
                cctvState = 1
                passwordFailActive = true

            else
                passwordFailActive = true
            end
            keyArray = {}
        end
        if (string.match(key, "%a") or string.match(key, "%d")) and #key == 1 and #keyArray <= 12  then
            keyArray[#keyArray + 1] = key
            print(keyArray[#keyArray])
        end
    end
end
function Minigame4:draw()
    
    if not loadingComplete then
        loading:draw(loadingScreen, 0, 0, 0 ,4, 4)
    else
        
        love.graphics.draw(login, 0, 0, 0, 4, 4)
        if passwordFailActive then
            love.graphics.draw(passwordFail, 0, 0, 0, 4, 4)
        end
        for i = 1, math.min(#keyArray, 12) do
            love.graphics.setColor{0, 0, 0}
            love.graphics.print("*", w/2 - 100 + i * 40, h/2 + 160, 0, 1, 1)
            love.graphics.setColor{1, 1, 1}
        end
    end
    love.graphics.rectangle('line', 1552, 900, 332, 104)
    if drawGavin then
        love.graphics.draw(gavin, 100, 250, 0, 2, 2)
    end
    if self.isDeleting then
        if not deleteComplete then
            deleting:draw(deleteScreen, 0, 0, 0 ,4, 4)
        else
            ParentMinigame:completeMinigame(4)
            ParentMinigame:setMinigame(nil)
            fade.isActive = true
        end
    end
    
end
function Minigame4:mousereleased(x,y,button)
end

return Minigame4