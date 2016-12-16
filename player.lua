local class = require 'middleclass'
local world = require 'world'
local timer = require 'timer'
local entity = require 'entity'
local player = class('player', entity)

local coinVX = love.audio.newSource("sound/coinpickup.wav", "static")

local frc, acc, dec, top, low = 700, 500, 2000, 350, 50

function player:load(x, y, w, h)
	self:initialize(world.bump, x, y, w, h)
	self.onGround = false
	self.wallJumpLeft = false
	self.wallJumpRight = false

	self.jumpFactor = -400
	self.wallJumpFactor = 350
	self.wallVelocity = 200
	self.score = 0
	self.dead = false
end

function player:update(dt)
	self.onGround = false
	self:applyGravity(dt)
	self:applyCollisions(dt)
	self:applyWallVelocity(dt)
    self:move(dt)
    self:checkWallJump()
end

function collisionFilter(item, other)
	if other.type == "coin" then
		return "cross"
	else
		return "slide"
	end
end

function player:applyCollisions(dt)
	local futureX, futureY = self.x + (self.vx * dt), self.y + (self.vy * dt)
	local nextX, nextY, cols, len = world.bump:move(self, futureX, futureY, collisionFilter)

	for i = 1, len do
		local col = cols[i]

		if col.other.type ~= "coin" then
			self:applyCollisionNormal(col.normal.x, col.normal.y)
		end

		if col.normal.y == -1 then
			self.onGround = true
		end

		if col.other.type == "spike" then
			self.dead = true
		end
		if col.other.type == "coin" then
			self.score = self.score + 1
			world.bump:remove(col.other)
			if coinVX:isPlaying() then
				coinVX:stop()
				coinVX:play()
			else
				coinVX:play()
			end
		end
	end

	self.x = nextX
	self.y = nextY
end

function player:applyWallVelocity(dt)
	if (self.wallJumpRight or self.wallJumpLeft) and self.vy > 0 then
		if self.vy < self.wallVelocity then
			self.vy = self.vy + low * dt
		else
			self.vy = self.wallVelocity
		end
	end
end

function player:move(dt)
	local lk = love.keyboard
    local vx = self.vx

    if lk.isDown('right') then
        if vx < 0 then
            vx = vx + dec * dt
        elseif vx < top then
            vx = vx + acc * dt
        end
    elseif lk.isDown('left') then
        if vx > 0 then
            vx = vx - dec * dt
        elseif vx > -top then
            vx = vx - acc * dt
        end
    else
        if math.abs(vx) < low then
            vx = 0
        elseif vx > 0 then
            vx = vx - frc * dt
        elseif vx < 0 then
            vx = vx + frc * dt
        end
    end

	self.vx = vx
end

function player:checkWallJump(dt)
	self.wallJumpLeft = false
	self.wallJumpRight = false

	local items, len = world.bump:getItems()
	local wallJumpWidth = 2
	for i = 1, len do
		local item = items[i]
		local x1, x2 = self.x - wallJumpWidth, self.x + self.w
		local y = self.y
		local h = self.h

		if item.type == "solid" then
			-- Check left side for wall jumping
			if x1 < item.x + item.width and x1 + wallJumpWidth > item.x and
			y < item.y + item.height and y + h > item.y then
				self.wallJumpLeft = true
			end

			-- Check right side for wall jumping
			if x2 < item.x + item.width and x2 + wallJumpWidth > item.x and
			y < item.y + item.height and y + h > item.y then
				self.wallJumpRight = true
			end
		end
	end
end


function player:jump(key)
	if key == 'up' then
		if self.onGround then
			self.vy = self.jumpFactor
		end
		if self.wallJumpRight and not self.onGround then
			self.vx = -self.wallJumpFactor
			self.vy = self.jumpFactor
		end
		if self.wallJumpLeft and not self.onGround then
			self.vx = self.wallJumpFactor
			self.vy = self.jumpFactor
		end
	end
end

return player