function newTimer(time,callback)
    local expired = false
    local timer = {}
    
    function timer.update(dt)
         if time < 0 then
               expired = true
               callback()
         end
         time = time - dt         
    end

    function timer.isExpired()
        return expired
    end

    function timer.getCurrentTime()
        local minutes = math.floor(time / 60)
        local seconds = math.floor(time % 60)
        return string.format("%d:%02d", minutes, seconds)
    end

    return timer
end

return newTimer