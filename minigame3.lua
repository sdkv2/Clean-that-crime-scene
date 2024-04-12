-- minigame3.lua
local Minigame3 = {}
Minigame3.__index = Minigame3
local anim8 = require 'libraries/anim8'
local butlerSheet = love.graphics.newImage('sprites/ddrbutler.png')
local g = anim8.newGrid(128, 160, butlerSheet:getWidth(), butlerSheet:getHeight())
local butler = anim8.newAnimation(g('1-4', 1), 0.1)
local background = love.graphics.newImage('sprites/blurredbackground.png')
local sound -- Define the sound variable outside the function
local upSound = love.audio.newSource('sfx/up.wav', 'static')
local downSound = love.audio.newSource('sfx/down.wav', 'static')
local leftSound = love.audio.newSource('sfx/left.wav', 'static')
local rightSound = love.audio.newSource('sfx/right.wav', 'static')
local sound = nil
local book = love.graphics.newImage('sprites/booknoback.png')
local arrow = love.graphics.newImage('sprites/arrows.png')
local g2 = anim8.newGrid(32, 32, arrow:getWidth(), arrow:getHeight())
local arrowAnim = anim8.newAnimation(g2('1-4', 1), 0.4)
local fail = love.audio.newSource('sfx/fail.wav', 'static')
local failimage = love.graphics.newImage('sprites/fail.png')
local win = love.audio.newSource('sfx/win.wav', 'static')
local winimage = love.graphics.newImage('sprites/winimg.png')
local gkiransprite = love.graphics.newImage('sprites/gkiranportrait.png')
local g3 = anim8.newGrid(128, 128, gkiransprite:getWidth(), gkiransprite:getHeight())
local gkiranportrait = anim8.newAnimation(g3('1-2', 1), 0.3)
local tv = love.graphics.newImage('sprites/tv.png')
local blur = love.graphics.newImage('sprites/blur.png')
local hit = love.audio.newSource('sfx/punch.wav', 'static')
local dead = love.audio.newSource('sfx/death.wav', 'static')
function Minigame3.new(Parent)
    local self = setmetatable({}, Minigame3)
    self.stages = {
        {directions = {'up', 'down', 'left', 'right'}, durations = {0.5, 0.5, 0.5,0.5}}, -- Stage 1
        {directions = {'down', 'down', 'down', 'left', 'right', 'up', 'right', 'right'}, durations = {0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25}}, -- Stage 2
        {directions = {'up', 'right', 'down', 'left', 'down'}, durations = {0.5, 0.5, 0.5,0.5, 0.5}}, -- Stage 3
        {directions = {'down', 'left', 'right', 'up', 'right',  'up', 'right', 'down', 'left', 'down'}, durations = {0.5, 0.5, 0.5,0.5,0.25,0.25,0.25,0.25,0.25,0.25,0.25, 0.5, 0.5}}, -- Stage 4
    }
    self.ParentMinigame = Parent
    self.endGame = false
    self.currentStage = 1
    self.currentDirection = 1
    self.allowInput = false
    self.timer = 0
    self.sound = nil
    self.started = false
    self.delay = 0.5
    self.fail = false
    self.kiranAlpha = 1.0


    return self
end
function Minigame3:generateSound(direction)
    if direction == 'up' then
        return upSound
    end
    if direction == 'down' then
        return downSound
    end
    if direction == 'left' then
        return leftSound
    end
    if direction == 'right' then
        return rightSound
    end
end

function Minigame3:update(dt)
    if not self.endGame then
    self:processStages(dt)
    else
        if not dead:isPlaying() then
            self.ParentMinigame:completeMinigame(3)
            fade.isActive = true
        end
    end
end

function Minigame3:processStages(dt)
    if self.delay > 0 then
        if self.delay < 0.25 then
            if sound then
            sound:stop()
            gkiranportrait:gotoFrame(1)
            end
        end
        self.delay = self.delay - dt
        return
    end
        if not self.allowInput then
                self.win = false
                self.fail = false   
                self.timer = self.timer + dt
                if self.currentDirection > #self.stages[self.currentStage].directions then
                    if self.timer >= self.stages[self.currentStage].durations[#self.stages[self.currentStage].durations] then
                        self.allowInput = true
                        self.drawArrow = false
                        self.sound:stop()
                        self.currentDirection = 1
                    end
                
                    return
                end
                local stage = self.stages[self.currentStage]
                if self.timer >= stage.durations[self.currentDirection] then
                    self.drawArrow = true
                    
                    print(stage.directions[self.currentDirection])
                    if self.sound then
                        self.sound:stop()
                    end
                    self.sound = self:generateSound(stage.directions[self.currentDirection])
                    self.sound:play()
                    Minigame3:drawArrow(stage.directions[self.currentDirection])

                    self.timer = 0
                    self.currentDirection = self.currentDirection + 1
                end
            end

end

function Minigame3:drawArrow(direction)
    if direction == 'up' then
        arrowAnim:gotoFrame(1)
    elseif direction == 'down' then
        arrowAnim:gotoFrame(2)
    elseif direction == 'left' then
        arrowAnim:gotoFrame(4)
    elseif direction == 'right' then
        arrowAnim:gotoFrame(3)
    elseif direction == 'none' then
        self.drawArrow = false
    end
end

function Minigame3:mousepressed(x, y, button)

end
-- Add this to each minigame class

function Minigame3:keypressed(key)
    if not self.allowInput then
        return
    end
    if sound then
        sound:stop()
    end
    if key == 'w' or key == 'up' then
        butler:gotoFrame(1)
        sound = Minigame3:generateSound('up')
        sound:play()
        playerDirection = 'up'
    elseif key == 'a' or key == 'left' then
        sound = Minigame3:generateSound('left')
        sound:play()
        butler:gotoFrame(4)
        playerDirection = 'left'
    elseif key == 's' or key == 'down' then
        playerDirection = 'down'
        sound = Minigame3:generateSound('down')
        sound:play()
        butler:gotoFrame(2)
    elseif key == 'd' or key == 'right' then
        playerDirection = 'right'
        sound = Minigame3:generateSound('right')
        sound:play()
        butler:gotoFrame(3)
    end
    if playerDirection == self.stages[self.currentStage].directions[self.currentDirection] then
        self.currentDirection = self.currentDirection + 1
        print('correct')
        if self.currentDirection > #self.stages[self.currentStage].directions then
            if self.currentStage == #self.stages then
                sound:stop()
                self.endGame = true
            end

            self.kiranAlpha = self.kiranAlpha - 0.25
            gkiranportrait:gotoFrame(2)
            hit:play()
            if self.kiranAlpha <= 0 then
                dead:play()
                self.endGame = true
            end
            self.win = true
            self.delay = 1
            self.currentStage = self.currentStage + 1
            self.currentDirection = 1
            self.allowInput = false
            self.timer = 0
        end
    else
        if sound then
            sound:stop()
        end
        fail:play()
        playerDirection = 'none'
        self.fail = true
        self.delay = 0.5
        self.currentDirection = 1
        self.allowInput = false
        self.timer = 0.5
    end

    
end

function Minigame3:drawKiran()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', w/2 - 130, h/2 - 400, 128 * 2.5, 128 * 2.5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("<-- Live Kiran reaction", w/2 + 250, h/2 - 350)
    print(self.kiranAlpha)
    love.graphics.setColor(1, 1, 1, self.kiranAlpha)
    gkiranportrait:draw(gkiransprite, w/2 - 130, h/2 - 400, 0, 2.5, 2.5)
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.draw(blur, w/2 - 150, h/2 - 500, 0, 3, 3)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(tv, w/2 - 150, h/2 - 500, 0, 3, 3)

end

function Minigame3:draw()
    love.graphics.draw(background, 0, 0, 0, 2.5, 2.5)
    butler:draw(butlerSheet, w/2 - 800, h/2 - 260, 0 ,5 ,5)
    love.graphics.draw(book, w/2 + 250, h/2 - 150, 0, 5, 5)
    if self.drawArrow then
        arrowAnim:draw(arrow, w/2 + 460, h/2 - 50, 0, 6, 6)
    end
    if not self.drawArrow and self.win then
        love.graphics.draw(winimage, w/2 + 460, h/2 - 50, 0, 6, 6)
    end
    if self.fail then
        love.graphics.draw(failimage, w/2 + 460, h/2 - 50, 0, 6, 6)
    end
    self:drawKiran()
end
function Minigame3:mousereleased(x,y,button)
end

return Minigame3