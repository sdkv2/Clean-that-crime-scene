-- minigame1.lua
local Minigame1 = {}
Minigame1.__index = Minigame1
local anim8 = require 'libraries/anim8'
local customFont = love.graphics.newFont('MS_PAIN.ttf', 72) -- Change the path and size to match your font

function Minigame1.new(ParentMinigame)
    local self = setmetatable({}, Minigame1)
    self.ParentMinigame = ParentMinigame

    self.bowlingball = love.graphics.newImage('sprites/bowling.png')
    self.bowlingballWidth = self.bowlingball:getWidth()
    self.bowlingballHeight = self.bowlingball:getHeight()
    self.bowlingballGrid = anim8.newGrid(240, 160, self.bowlingballWidth, self.bowlingballHeight)
    self.bowlingballAnimation = anim8.newAnimation(self.bowlingballGrid('1-35', 1), 0.1)

    self.spriteWidth, self.spriteHeight = self.bowlingballAnimation:getDimensions()
    self.frameChangeCounter = 0
    self.frameChangeThreshold = 0.05
    self.texture = love.graphics.newImage('sprites/blood.png') 
    self.textureWidth, self.textureHeight = self.texture:getDimensions()
    self.FrameSpin = 0
    self.completedIndex = 1
    self.letterChangeThreshold = 0.3
    self.letterChangeCounter = 0
    self.textures = {

        {
            y = h/2,
            offset = 650,
            frameStart = 1,
            frameEnd = 10,
            opacity = 1
        },
        {
            y = h/2 - 170,
            offset = 750,
            frameStart = 2,
            frameEnd = 8,
            opacity = 1
        },
        {
            y = h/2 - 130,
            offset = 750,
            frameStart = 10,
            frameEnd = 17,
            opacity = 1
        },
        -- Add more textures here...
    }
    return self
    
end

function Minigame1:keypressed(key)
    -- Handle key press for Minigame1
    if key == 'space' then
        self.ParentMinigame:setMinigame(nil)
    end
end
function Minigame1:update(dt)
    if #self.textures == 0 then
        if self.FrameSpin == 0 then
            self.bowlingballAnimation:gotoFrame(1)
        end
        self.bowlingballAnimation:update(dt)

        self.FrameSpin = self.FrameSpin + dt
        if self.FrameSpin >= 3.6 then
            fade.isActive = true
        end
        if self.FrameSpin >= 3.8 then
            self.ParentMinigame:setMinigame(nil)
        end

        -- Increment letterChangeCounter and check if it's time to add a new letter
        self.letterChangeCounter = self.letterChangeCounter + dt
        if self.letterChangeCounter >= self.letterChangeThreshold then
            self.completedIndex = math.min(self.completedIndex + 1, 9) -- 9 is the length of "completed"
            self.letterChangeCounter = 0
        end
 
    else

        local totalFrames = 35 -- Change this to the number of frames in your animation

        self.frameChangeCounter = self.frameChangeCounter + dt

        if self.frameChangeCounter >= self.frameChangeThreshold then
            if love.keyboard.isDown('right') then
                local currentFrame = self.bowlingballAnimation.position
                self.bowlingballAnimation:gotoFrame((currentFrame % totalFrames) + 1)
            elseif love.keyboard.isDown('left') then
                local currentFrame = self.bowlingballAnimation.position
                self.bowlingballAnimation:gotoFrame(((currentFrame - 2) % totalFrames) + 1)
            end
            self.frameChangeCounter = 0
        end

        local currentFrame = self.bowlingballAnimation.position

        for i, texture in ipairs(self.textures) do
            if currentFrame >= texture.frameStart and currentFrame <= texture.frameEnd then
                texture.x = ((w / 30) * (currentFrame - texture.frameStart)) + texture.offset
            end
        end
    end
end
function Minigame1:draw()
    if #self.textures == 0 then
        love.graphics.setFont(customFont)
        love.graphics.print(string.sub("completed", 1, self.completedIndex), w/2 - 200, 100, 0, 1, 1)
    end
    self.bowlingballAnimation:draw(self.bowlingball, w/2, h/2 + 100, 0, 6, 7, self.spriteWidth/2, self.spriteHeight/2)
    local currentFrame = self.bowlingballAnimation.position
    for i, texture in ipairs(self.textures) do
        if currentFrame >= texture.frameStart and currentFrame <= texture.frameEnd then
            love.graphics.setColor(1, 1, 1, texture.opacity) 
            love.graphics.draw(self.texture, texture.x, texture.y, 0, 3, 3)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
        love.graphics.print(currentFrame, 10, 10, 0, 3, 3)
    end
    

function Minigame1:mousepressed(x, y, button)
    if button == 1 then
        for i = #self.textures, 1, -1 do
            local texture = self.textures[i]
            local textureWidth, textureHeight = self.texture:getDimensions()
            textureWidth, textureHeight = textureWidth * 3, textureHeight * 3 -- Adjust for scale
            if texture.x and texture.y and x >= texture.x and x <= texture.x + textureWidth and y >= texture.y and y <= texture.y + textureHeight then
                if texture.opacity then
                    texture.opacity = texture.opacity - 0.5
                    if texture.opacity <= 0 then
                        table.remove(self.textures, i)
                    end
                end
                break 
            end
        end
    end
end

return Minigame1