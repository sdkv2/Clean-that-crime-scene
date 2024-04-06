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
local particles = {x=-248, y=-43}

local image1 = LG.newImage("circle.png")
image1:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 10)
ps:setColors(1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0.5, 1, 1, 1, 0)
ps:setDirection(1.5395565032959)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(19.872407913208)
ps:setEmitterLifetime(0)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 226.18925476074, 0, 918.31121826172)
ps:setLinearDamping(-0.00020284384663682, -0.0018255945760757)
ps:setOffset(50, 50)
ps:setParticleLifetime(1.8115569353104, 2.2141251564026)
ps:setRadialAcceleration(0, -0.10077489167452)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.30109423398972)
ps:setSizeVariation(0.45047923922539)
ps:setSpeed(414.79537963867, 724.57849121094)
ps:setSpin(-0.48991990089417, 3.5120272636414)
ps:setSpinVariation(0)
ps:setSpread(0.32911923527718)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=10, blendMode="add", shader=nil, texturePath="circle.png", texturePreset="circle", shaderPath="", shaderFilename="", x=0, y=0})

return particles
