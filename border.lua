function border(dt, rectangles, target, inverted, chat)
    local invert = inverted or false

    local topRectHeight = rectangles and rectangles[1] and rectangles[1].height or 0
    local bottomRectHeight = rectangles and rectangles[2] and rectangles[2].height or 0

    local screenX, screenY = cam:cameraCoords(player.x, player.y)
    local targetX, targetY = cam:cameraCoords(target.x, target.y)

    local worldX, worldY = cam:cameraCoords(0, h)
    local topComplete = false
    local bottomComplete = false
    
    local lowerY = math.min(screenY - player.spriteHeight - 80 * zoom, targetY - target.height * zoom * target.scale * 0.5)
    local higherY = math.max(screenY + player.spriteHeight * zoom, targetY + target.height * zoom * target.scale * 0.5)
    

    if chat then
        bottomRectHeight = rectangles and rectangles[1] and rectangles[1].height or 0
        higherY = h - 300
    elseif (screenHeight - higherY) < 250 then
        higherY = screenHeight - 250
    end

    if invert then
        newTopRectHeight = topRectHeight - math.abs(lowerY - topRectHeight) * dt * 3
        newBottomRectHeight = bottomRectHeight - math.abs(higherY - (h - bottomRectHeight)) * dt * 3
        if newTopRectHeight < 5 and newBottomRectHeight < 5 then
            bottomComplete = true
            topComplete = true
        end
    else
        newTopRectHeight = topRectHeight + math.abs(lowerY - topRectHeight) * dt * 3
        newBottomRectHeight = bottomRectHeight + math.abs(higherY - (h - bottomRectHeight)) * dt * 3
        if newTopRectHeight > lowerY - 40  then
            newTopRectHeight = topRectHeight
            topComplete = true
        end
    
        if h - newBottomRectHeight < higherY + 40 then
            newBottomRectHeight = bottomRectHeight
            bottomComplete = true
        end
    end
    if chat then
        rectangles = {
            {x = 0, y = h - newBottomRectHeight, width = w, height = newBottomRectHeight}
        }
    else
        rectangles = {
            {x = 0, y = 0, width = w, height = newTopRectHeight},
            {x = 0, y = h - newBottomRectHeight, width = w, height = newBottomRectHeight}
        }
    end

    local complete = topComplete and bottomComplete
    return rectangles, complete
end

return border