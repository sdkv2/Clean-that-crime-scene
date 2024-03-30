--[[
module = {
	x=emitterPositionX, y=emitterPositionY,
	[1] = {
		system=particleSystem1,
		kickStartSteps=steps1, kickStartDt=dt1, emitAtStart=count1,
		blendMode=blendMode1, shader=shader1,
		texturePreset=preset1, texturePath=path1,
		shaderPath=path1, shaderFilename=filename1,
		x=emitterOffsetX, y=emitterOffsetY
	},
	[2] = {
		system=particleSystem2,
		...
	},
	...
}
]]
local LG        = love.graphics
local particles = {x=-175, y=-73}

local image1 = LG.newImage("bubble.png")
image1:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 20)
ps:setColors(1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(4.7941241264343)
ps:setEmitterLifetime(-1)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(16.285715103149, 16.36607170105)
ps:setParticleLifetime(1.2408268451691, 2.6663997173309)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(2.4297473430634)
ps:setSizeVariation(0.7635782957077)
ps:setSpeed(48.64582824707, 215.83419799805)
ps:setSpin(0.43980753421783, 0)
ps:setSpinVariation(0)
ps:setSpread(1.5857563018799)
ps:setTangentialAcceleration(0.11222907155752, 1.010061621666)
ps:setQuads(LG.newQuad(0, 0, 32, 39, 345, 39), LG.newQuad(32, 0, 32, 39, 345, 39), LG.newQuad(64, 0, 32, 39, 345, 39), LG.newQuad(96, 0, 32, 39, 345, 39), LG.newQuad(128, 0, 32, 39, 345, 39), LG.newQuad(160, 0, 32, 39, 345, 39), LG.newQuad(192, 0, 32, 39, 345, 39), LG.newQuad(224, 0, 32, 39, 345, 39), LG.newQuad(256, 0, 32, 39, 345, 39), LG.newQuad(288, 0, 32, 39, 345, 39))
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=6, blendMode="add", shader=nil, texturePath="bubble.png", texturePreset="", shaderPath="", shaderFilename="", x=0, y=0})

return particles
