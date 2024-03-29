local json = require 'libraries/JSON'
local chat = {}

local invert = false
chat.CurrentChar = 1
chat.CurrentDialogue = nil
chat.TimeElapsed = 0 -- New variable to keep track of time
chat.complete = true
chat.rectangles = {}
chat.line = 1
chat.invert = false
chat.keys = {} -- Make keys a member of the chat table
chat.speaker = nil
chat.chatting = false

chat.firstSpeaker = nil
chat.secondSpeaker = nil

function chat:loadJson(filePath)
    local f = io.open(filePath, "r")
    local content = f:read("*all")
    f:close()
    return json:decode(content)
end

function chat:chat(npc, subtable)
    player.collider:setLinearVelocity(0, 0)
    chat.complete = false
    chat.invert = false
    self.index = 1
    local dialogue = chat:loadJson('npcs/dialogue.json')
    self.npc = npc
    self.subtable = subtable
    chat.chatting = true
    if dialogue and dialogue[npc] and dialogue[npc][subtable] then
        self.CurrentDialogue = dialogue[npc][subtable]
        self.line = 1
        updateAnim(self.CurrentDialogue[self.line].speaker)
        self.CurrentLine = self.CurrentDialogue[self.line].dialogue
    end
    local customFont = love.graphics.newFont('MS_PAIN.ttf', 45) -- Change the path and size to match your font
    love.graphics.setFont(customFont)

end

function updateAnim(s)
    local portrait
    local emotion
    local i = 0    
    for word in string.gmatch(s, '([^/]+)') do
        i = i + 1
        if i == 1 then
            portrait = word
        elseif i == 2 then
            emotion = word
        end
    end

    if portrait == 'butler' then
        player.portraitAnimation = player.portraitExpressions[emotion]
        chat.speaker = player
        chat.firstSpeaker = player
    end
    if portrait == 'kyle' then
        kyle.portraitAnimation = kyle.portraitExpressions[emotion]
        chat.speaker = kyle
        chat.secondSpeaker = kyle

    end
end
function chat:nextLine()
    if self.CurrentDialogue then
        if self.CurrentChar <= #self.CurrentLine then
            self.CurrentChar = #self.CurrentLine
        else
            self.line = self.line + 1

            if self.CurrentDialogue[self.line] then
                updateAnim(self.CurrentDialogue[self.line].speaker)
                self.CurrentLine = self.CurrentDialogue[self.line].dialogue
                self.CurrentChar = 1
            else
                chat:endChat()
            end
        end
    end
end

function chat:endChat()
    chat.invert = true
    chat.complete = false
    self.CurrentDialogue = nil
    self.CurrentLine = nil
    self.CurrentChar = 0
    self.line = 1
    self.keys = {}
    chat.chatting = false
    target = nil
end

function chat:playSound()
    local length = 0.1 -- The length of the sound in seconds
    local rate = 44100 -- The sample rate of the sound
    local frequency = math.random(75, 100)
    local soundData = love.sound.newSoundData(math.floor(length*rate), rate, 16, 1)
    local unisonCount = 4 -- The number of unison voices
    local detuneAmount = 0.1 -- The amount of detuning for the unison voices
    local phase = {}
    for j=1, unisonCount do
        phase[j] = 0
    end

    local fadeTime = 0.01 
    local fadeSamples = fadeTime * rate 

    for i=0, soundData:getSampleCount() - 1 do
        local t = i / rate
        local volume = 0.5 * (1 + math.sin(0.1 * t)) / unisonCount 

        if i < fadeSamples then
            volume = volume * (i / fadeSamples)
        elseif i > soundData:getSampleCount() - fadeSamples then
            volume = volume * ((soundData:getSampleCount() - i) / fadeSamples)
        end

        local sample = 0
        for j=1, unisonCount do
            local detune = 1 + (j - 1) * detuneAmount
            phase[j] = phase[j] + (frequency * detune / rate) 
            phase[j] = phase[j] % 1
            local triangle = 2 * math.abs(2 * phase[j] - 1) - 1
            sample = sample + volume * triangle
        end
        soundData:setSample(i, sample)
    end
    local sound = love.audio.newSource(soundData)

    local filterSettings = {
        type = 'lowpass',
        volume = 1,
        highgain = 0.5
    }
    sound:setFilter(filterSettings)

    -- Play the sound
    love.audio.play(sound)
end

function chat:progressChat(dt)
    if self.CurrentLine and self.CurrentChar < #self.CurrentLine then
        if chat.speaker then
            chat.speaker.portraitAnimation:update(dt)
        end
    else
        player.portraitAnimation:gotoFrame(1)
        if chat.speaker  then
            chat.speaker.portraitAnimation:gotoFrame(1)
        end
    end
    self.TimeElapsed = self.TimeElapsed + dt
    if self.CurrentLine and self.CurrentChar <= #self.CurrentLine and self.TimeElapsed >= 0.05 then
        self.CurrentChar = self.CurrentChar + 1
        self.TimeElapsed = 0 -- Reset the timer after updating the character
        -- Call the playSound function
        self:playSound()
    end
    -- Check if the next character is available before updating self.CurrentLine
    if self.CurrentDialogue and self.keys[self.line] then
        self.CurrentLine = self.CurrentDialogue[self.keys[self.line]]
    end
end

function chat:update(dt)
    
    if invert == false then
        self:progressChat(dt)
    end
    if chat.complete == false then
        chat.rectangles, chat.complete = border(dt, chat.rectangles, chat.invert, true)
    else
    end

end

function chat:draw()

    for num, rect in ipairs(chat.rectangles) do
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.rectangle('fill', rect.x - 5, rect.y + 65, rect.width + 10, rect.height - 65)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle('fill', rect.x, rect.y + 70, rect.width, rect.height - 70)
        if num == 1 then
            love.graphics.setColor(1,1,1)
            if chat.firstSpeaker then
                if chat.speaker == chat.firstSpeaker then
                    chat.firstSpeaker.portraitAnimation:draw(chat.firstSpeaker.portraitSheet, rect.x, h - rect.height, 0, 2, 2)
                else
                    love.graphics.setColor(0.3, 0.3, 0.3) -- Grey out the non-speaking character
                    chat.firstSpeaker.portraitAnimation:draw(chat.firstSpeaker.portraitSheet, rect.x, h - rect.height, 0, 2, 2) -- Slide the portrait
                    love.graphics.setColor(1,1,1) -- Reset the color
                end
            end
            if chat.secondSpeaker then
                if chat.speaker == chat.secondSpeaker then
                    chat.secondSpeaker.portraitAnimation:draw(chat.secondSpeaker.portraitSheet, rect.x + rect.width - 128 * 2, h - rect.height, 0, 2 ,2)
                else
                    love.graphics.setColor(0.3, 0.3, 0.3) -- Grey out the non-speaking character
                    chat.secondSpeaker.portraitAnimation:draw(chat.secondSpeaker.portraitSheet, rect.x + rect.width - 128 * 2, h - rect.height, 0, 2 ,2) -- Slide the portrait
                    love.graphics.setColor(1,1,1) -- Reset the color
                end
            end
            if self.CurrentLine then
                love.graphics.print(string.sub(self.CurrentLine, 1, self.CurrentChar), rect.x + 300, h - rect.height + 100, 0, 1, 1)
            end
        end
    end
end
return chat
