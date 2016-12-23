local class = require 'middleclass'
local world = require 'world'
local timer = require 'timer'
local entity = require 'entity'
local particle = class('particle', entity)
local particles = {}

function particles:load(numParticles, duration, spread, ox, oy, w, h)
	self.particles = {}
	self.len = numParticles
	for i = 1, numParticles do
		local p = particle:new(world.bump, ox, oy, w, h, 'particle')
		p.vx = math.random(-spread, spread)
		p.vy = math.random(-spread, -spread/3)
		p.frc = 500
		p.low = 50
		p.timer = timer:new(math.random(duration/2, duration))
		self.particles[#self.particles+1] = p
	end
end

local function collisionFilter(item, other)
	if other.name == 'solid' then
		return 'slide'
	end
	return 'cross'
end

function particles:update(dt)
	if self.len then
		for i = 1, self.len do
			local p = self.particles[i]

			p:applyGravity(dt)
			local futureX = p.x + p.vx * dt
			local futureY = p.y + p.vy * dt
			local goalX, goalY, cols, len = world.bump:move(p, futureX, futureY, collisionFilter)
			for j = 1, len do
				local col = cols[j]
				if col.other.name == 'solid' then
					p:applyCollisionNormal(col.normal.x, col.normal.y)
					if col.normal.y == -1 or col.normal.y == 1 then
						if math.abs(p.vx) < p.low then
				            p.vx = 0
				        elseif p.vx > 0 then
				            p.vx = p.vx - p.frc * dt
				        elseif p.vx < 0 then
				            p.vx = p.vx + p.frc * dt
				        end
					end
				end
			end
			p.x = goalX
			p.y = goalY
		end
	end
end

function particles:draw()
	if self.len then
		for i = 1, self.len do
			local p = self.particles[i]
			p:draw({138,7,7})
		end
	end
end

return particles