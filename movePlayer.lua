local function move(player, dt)
    
    local dx, dy = 0, 0  -- Initialize dx and dy

    if love.keyboard.isDown("lshift") then
        player.speed = 500
        player.currentAnimation:update(dt)
    else
        player.speed = 350
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        dx = dx + 1
        player.isMoving = true
        player.currentAnimation = player.animations.right
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        dx = dx - 1
        player.isMoving = true
        player.currentAnimation = player.animations.left
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        dy = dy + 1
        player.currentAnimation = player.animations.down
        player.isMoving = true

    elseif love.keyboard.isDown("up") or love.keyboard.isDown("w")then
        dy = dy - 1
        player.currentAnimation = player.animations.up
        player.isMoving = true
    end

    -- Normalize the vector
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx, dy = dx / len, dy / len
    end
    
    player.collider:setLinearVelocity(dx * player.speed, dy * player.speed)

    return
end

return move