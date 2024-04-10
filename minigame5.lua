-- minigame5.lua
local Minigame5 = {}
Minigame5.__index = Minigame5
local background = love.graphics.newImage('sprites/blurredbackground.png')
local bookbackground = love.graphics.newImage('sprites/book.png')

function Minigame5.new(Parent)
    local self = setmetatable({}, Minigame5)
    world:update(0) 
    player.collider:setLinearVelocity(0, 0)
    love.graphics.setFont(love.graphics.newFont('MS_PAIN.ttf', 36))

    self.ParentMinigame = Parent
    self.pages = {"Among ussssssssssssssssssssssssssssssss", "Among us 2ssssssssssssssss", "Among wadawdwadus 3", "Amonawdawdwadg us 4"}
    self.currentPage = 1
    return self
end

function Minigame5:update(dt)

end

function Minigame5:mousepressed(x, y, button)
end

function Minigame5:keypressed(key)
    if key == 'j' then
        self.ParentMinigame:setMinigame(nil)
        fade.isActive = true
    elseif key == 'left' then
        self.currentPage = math.max(1, self.currentPage - 2)
    elseif key == 'right' then
        self.currentPage = math.min(#self.pages - 1, self.currentPage + 2)
    end
end

function Minigame5:draw()
    love.graphics.draw(background, 0, 0, 0, 2.5, 2.5)
    love.graphics.draw(bookbackground, w/2 - 470, h/2 - 340, 0, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.pages[self.currentPage], w/2 - 400, h/2 - 310, 360, 'center') 
    love.graphics.printf(self.pages[self.currentPage + 1], w/2 + 70, h/2 - 300, 360, 'center') 
    love.graphics.setColor(1, 1, 1)
end

function Minigame5:mousereleased(x,y,button)
end

return Minigame5