-- minigame1.lua
local Minigame1 = {}
Minigame1.__index = Minigame1
local anim8 = require 'libraries/anim8'
local customFont = love.graphics.newFont('MS_PAIN.ttf', 72) -- Change the path and size to match your font
local keyboardArrows = love.graphics.newImage('sprites/keyboard_arrows.png')
local horizontalArrows = love.graphics.newImage('sprites/keyboard_arrows_horizontal.png')
local mouse = love.graphics.newImage('sprites/mouse.png')
local mouseClick = love.graphics.newImage('sprites/mouse_left.png')
local currentImage2 = mouse
local currentImage = keyboardArrows
local lastSwitch = love.timer.getTime()
local allParticleData = require 'libraries.bubbles'
local anim8 = require 'libraries/anim8'
local bloodSplatters = love.graphics.newImage('sprites/blood.png')
local g = anim8.newGrid(128, 128, bloodSplatters:getWidth(), bloodSplatters:getHeight())
local background = love.graphics.newImage('sprites/blurredbackground.png')
local bubbles = love.audio.newSource("sfx/bubbles.wav", "static")
function Minigame1:initializeOrResetParticles()
	for _, particleData in ipairs(allParticleData) do
		-- Note that particle systems are already started when created, so we
		-- don't need to call particleSystem:start() at any point.
		local particleSystem = particleData.system

		particleSystem:reset()
		particleSystem:setPosition(allParticleData.x+particleData.x, allParticleData.y+particleData.y)

		for step = 1, particleData.kickStartSteps do -- kickStartSteps may be 0.
			particleSystem:update(particleData.kickStartDt)
		end     
        particleData.system:stop() -- Stop emitting particles when mouse button is released

	end
end



function Minigame1.new(ParentMinigame)
    Minigame1:initializeOrResetParticles()
    love.graphics.setFont(customFont)
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
    self.textureWidth, self.textureHeight = 128, 128
    self.FrameSpin = 0
    self.completedIndex = 1
    self.letterChangeThreshold = 0.3
    self.letterChangeCounter = 0
    self.textures = {

        {
            y = h/2 - 50,
            offset = 650,
            frameStart = 1,
            frameEnd = 10,
            opacity = 1
        },
        {
            y = h/2 - 50,
            offset = 850,
            frameStart = 1,
            frameEnd = 7,
            opacity = 1
        },
        {
            y = h/2 + 100,
            offset = 650,
            frameStart = 3,
            frameEnd = 9,
            opacity = 1
        },
        {
            y = h/2 - 130,
            offset = 750,
            frameStart = 7,
            frameEnd = 14,
            opacity = 1
        },
        {
            y = h/2 - 150,
            offset = 700,
            frameStart = 4,
            frameEnd = 11,
            opacity = 1
        },
        {
            y = h/2 - 100,
            offset = 700,
            frameStart = 10,
            frameEnd = 15,
            opacity = 1
        },
        {
            y = h/2 - 50,
            offset = 700,
            frameStart = 15,
            frameEnd = 23,
            opacity = 1
        },
        {
            y = h/2 - 100,
            offset = 700,
            frameStart = 20,
            frameEnd = 28,
            opacity = 1
        },
        {
            y = h/2 - 150,
            offset = 700,
            frameStart = 25,
            frameEnd = 33,
            opacity = 1
        },
        {
            y = h/2 - 200,
            offset = 700,
            frameStart = 28,
            frameEnd = 35,
            opacity = 1
        }
    }
    for i, texture in ipairs(self.textures) do
        texture.image = anim8.newAnimation(g(math.random(1,5), 1), 0.1)
    end
    return self
    
end

function Minigame1:keypressed(key)
    -- Handle key press for Minigame1
    if key == 'space' then
        self.ParentMinigame:setMinigame(nil)
    end
end
function Minigame1:updateTextures(dt)
    local currentFrame = self.bowlingballAnimation.position

    for i, texture in ipairs(self.textures) do
        if currentFrame >= texture.frameStart and currentFrame <= texture.frameEnd then
            texture.x = ((w / 30) * (currentFrame - texture.frameStart)) + texture.offset
        end
    end
end
function Minigame1:updateAnimation(dt)
    if self.FrameSpin == 0 then
        self.bowlingballAnimation:gotoFrame(1)
    end
    self.bowlingballAnimation:update(dt)

    self.FrameSpin = self.FrameSpin + dt
    if self.FrameSpin >= 3.5 then
        print('hi')
        fade.startFade()
    end
    if self.FrameSpin >= 3.8 then
        self.ParentMinigame:completeMinigame(1)
    end
end

function Minigame1:updateLetterChange(dt)
    -- Increment letterChangeCounter and check if it's time to add a new letter
    self.letterChangeCounter = self.letterChangeCounter + dt
    if self.letterChangeCounter >= self.letterChangeThreshold then
        self.completedIndex = math.min(self.completedIndex + 1, 9) -- 9 is the length of "completed"
        self.letterChangeCounter = 0
    end
end

function Minigame1:updateFrameChange(dt)
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
end
function Minigame1:updateImages()
    if love.timer.getTime() - lastSwitch >= 0.5 then
        -- Switch the image
        if currentImage2 == mouseClick then
            currentImage2 = mouse
        else
            currentImage2 = mouseClick
        end
        if currentImage == keyboardArrows then
            currentImage = horizontalArrows
        else
            currentImage = keyboardArrows
        end

        -- Update the time of the last switch
        lastSwitch = love.timer.getTime()
    end
end
function Minigame1:update(dt)
    local mouseX, mouseY = love.mouse.getPosition()

    if #self.textures == 0 then
        self:updateAnimation(dt)
        self:updateLetterChange(dt)
    else
        self:updateFrameChange(dt)
        self:updateTextures(dt)
    end
    self:updateImages()
    for _, particleData in ipairs(allParticleData) do
        particleData.system:update(dt)
        particleData.system:setPosition(mouseX, mouseY)
    end

end

function Minigame1:draw()
    love.graphics.draw(background, 0, 0, 0, 2.5, 2.5)
    love.graphics.print("Controls:", 50, h - 300, 0, 0.5, 0.5)
    love.graphics.draw(currentImage, 80, h - 250, 0, 2, 2)
    love.graphics.print("= Rotate ball", 200, h - 200, 0, 0.5, 0.5)
    love.graphics.draw(currentImage2, 80, h - 150, 0, 2, 2)
    love.graphics.print("= Clean blood", 200, h - 100, 0, 0.5, 0.5)

    if #self.textures == 0 then
        love.graphics.print(string.sub("completed", 1, self.completedIndex), w/2 - 200, 100, 0, 1, 1)
    end
    self.bowlingballAnimation:draw(self.bowlingball, w/2, h/2 + 100, 0, 5, 6, self.spriteWidth/2, self.spriteHeight/2)
    local currentFrame = self.bowlingballAnimation.position
    for i, texture in ipairs(self.textures) do
        if currentFrame >= texture.frameStart and currentFrame <= texture.frameEnd then
            love.graphics.setColor(1, 1, 1, texture.opacity) 
            texture.image:draw(bloodSplatters, texture.x, texture.y, 0, 1, 1)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
    for _, particleData in ipairs(allParticleData) do
		love.graphics.draw(particleData.system)
	end
end

    

function Minigame1:mousepressed(x, y, button)

    if button == 1 then
        for _, particleData in ipairs(allParticleData) do
            particleData.system:start() -- Start emitting particles
            particleData.system:emit(particleData.emitAtStart)
            love.audio.play(bubbles)
        end
        for i = #self.textures, 1, -1 do
            local texture = self.textures[i]
            local textureWidth, textureHeight = 128, 128
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

function Minigame1:mousereleased(x, y, button)
    if button == 1 then
        for _, particleData in ipairs(allParticleData) do
            particleData.system:stop() -- Stop emitting particles when mouse button is released
        end
    end
end

return Minigame1