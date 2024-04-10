-- minigame5.lua
local Minigame5 = {}
Minigame5.__index = Minigame5
local background = love.graphics.newImage('sprites/blurredbackground.png')
local bookbackground = love.graphics.newImage('sprites/book.png')

function Minigame5.new(Parent)
    local self = setmetatable({}, Minigame5)
    world:update(0) 
    player.collider:setLinearVelocity(0, 0)

    self.ParentMinigame = Parent
    self.pages = {"Among us", "Among us 2", "Among us 3", "Among us 4"} -- Add your text here
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
    love.graphics.printf(self.pages[self.currentPage], w/2 - 470, h/2 - 340, 200, 'center') -- Adjust the position and width as needed
    love.graphics.printf(self.pages[self.currentPage + 1], w/2, h/2 - 340, 200, 'center') -- Adjust the position and width as needed
end

function Minigame5:mousereleased(x,y,button)
end

return Minigame5