--timer.lua

local Timer = {}
Timer.__index = Timer

function Timer.new(time, callback)
    local self = setmetatable({}, Timer)
    self.time = time
    self.callback = callback
    self.expired = false
    self.coolfont = love.graphics.newFont('MS_PAIN.ttf', 100)

    return self
end

function Timer:update(dt)
    if self.time <= 0 then
        self.expired = true
        if self.callback then
            self.callback()
        end
    end
    self.time = self.time - dt
end

function Timer:isExpired()
    return self.expired
end

function Timer:getCurrentTime()
    local minutes = math.floor(self.time / 60)
    local seconds = math.floor(self.time % 60)
    return string.format("%d:%02d", minutes, seconds)
end

function Timer:draw()
    if self.expired then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print('Timer Expired', 100, 100)
    else
        self.timeRemain = self:getCurrentTime()
        
        love.graphics.setColor(0, 0, 0, 0.6)
        
        love.graphics.rectangle('fill', 100, 100, 200, 100, 100, 100, 15)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print(self.timeRemain, self.coolfont, 110, 80, 0, 1, 1)
    end
end

return Timer