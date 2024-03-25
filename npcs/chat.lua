local json = require 'libraries/JSON'
local chat = {}

chat.CurrentLine = nil
chat.CurrentChar = 1
chat.CurrentDialogue = nil
chat.TimeElapsed = 0 -- New variable to keep track of time

function chat:loadJson(filePath)
    local f = io.open(filePath, "r")
    local content = f:read("*all")
    f:close()
    return json:decode(content)
end

function chat:chat(npc, subtable)
    local dialogue = self:loadJson('npcs/dialogue.json')
    if dialogue and dialogue[npc] and dialogue[npc][subtable] then
        self.CurrentDialogue = dialogue[npc][subtable]
        -- Get the keys
        local keys = {}
        for k in pairs(self.CurrentDialogue) do
            table.insert(keys, k)
        end
        -- Sort the keys
        table.sort(keys)
        -- Set the first line
        self.CurrentLine = self.CurrentDialogue[keys[1]]
    end
end

function chat:progressChat(dt)
    self.TimeElapsed = self.TimeElapsed + dt
    if self.CurrentLine and self.CurrentChar <= #self.CurrentLine and self.TimeElapsed >= 0.05 then
        self.CurrentChar = self.CurrentChar + 1
        self.TimeElapsed = 0 -- Reset the timer after updating the character

        -- Generate a sound
        local length = 0.1 -- The length of the sound in seconds
        local rate = 44100 -- The sample rate of the sound
        local p = math.floor((love.math.random(100, 500) + 25) / 50) * 50 -- The period of the sound
        local soundData = love.sound.newSoundData(math.floor(length*rate), rate, 16, 1)
        for i=0, soundData:getSampleCount() - 1 do
            soundData:setSample(i, i%p<p/2 and 1 or -1)
        end

        -- Play the sound
        local sound = love.audio.newSource(soundData)
        love.audio.play(sound)
    end
end

function chat:update(dt)
    self:chat('explosion', '1')
    self:progressChat(dt)
    rectangles, complete = border(dt, rectangles, target, false, true)
end

function chat:draw()
    love.graphics.setColor(0,0,0)
    for num, rect in ipairs(rectangles) do
        love.graphics.rectangle('fill', rect.x, rect.y, rect.width, rect.height)
        if num == 1 then
            love.graphics.setColor(1,1,1)
            love.graphics.draw(love.graphics.newImage('sprites/butler_neutral.png'), rect.x, h - rect.height, 0, 2, 2)
            if self.CurrentLine then
                love.graphics.print(string.sub(self.CurrentLine, 1, self.CurrentChar), rect.x + 300, h - rect.height + 30, 0, 4, 4)
            end
        end
    end
end

return chat
