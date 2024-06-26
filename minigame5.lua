-- minigame5.lua
local Minigame5 = {}
Minigame5.__index = Minigame5
local background = love.graphics.newImage('sprites/blurredbackground.png')
local bookbackground = love.graphics.newImage('sprites/book.png')

function Minigame5.new(Parent)
    local self = setmetatable({}, Minigame5)
    world:update(0) 
    player.collider:setLinearVelocity(0, 0)
    love.graphics.setFont(love.graphics.newFont('MS_PAIN.ttf', 42))

    self.ParentMinigame = Parent
    self.pages = 
    {"Dear diary, \n \n this is my first time writing something in 12 years but I figured it was important enough to remember. I've discovered this thing called Looksmaxxing, and holy mew! Cannot wait to unleash my sigma rizz!",
    "Dear diary, \n \n my grandpa died today. I think he took me out of the will because I was low-key mogging him so im fr gonna exorcize his ghost tonight. I'll keep you updated on how it goes. ", 
    "*This page contains frantic scribbles detailing the exorcism process, it mentions a strange amount of dancing and arrows pointing in different directions*", 
    "Dear diary, \n \n I think I might be possessed by my grandpap's ghost. I've been seeing him in the mirror and he keeps telling me to 'get a job'. I'm not sure what that really means. BTW I also changed the PC password today for security. New code is 'password1'. ",}
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
    love.graphics.draw(bookbackground, w/2 - 600, h/2 - 460, 0, 10, 10)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.pages[self.currentPage], w/2 - 520, h/2 - 360, 500, 'left') 
    love.graphics.printf(self.pages[self.currentPage + 1], w/2 + 55, h/2 - 360, 500, 'left') 
    love.graphics.setColor(1, 1, 1)
end

function Minigame5:mousereleased(x,y,button)
end

return Minigame5