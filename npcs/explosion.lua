--explosion.lua

local x = require 'npcs/chat'

local chatting = {}

function chatting:interact(name)
    x:chat(name, '1')
end

return chatting
