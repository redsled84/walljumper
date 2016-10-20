local class = require 'middleclass'
local world = require 'world'
local timer = require 'timer'
local entity = require 'entity'
local player = class('player', entity)

local frc, acc, dec, top, low = 700, 500, 2000, 350, 50

function player:load(x, y, w, h)
	self:initialize(world.bump, x, y, w, h)
	self.onGround = false
	self.wallJumpLeft = false
	self.wallJumpRight = false

	self.jumpFactor = -400
	self.wallJumpFactor = 300
	self.wallVelocity = 175
end

function player:update(dt)
	self.onGround = false
	self:applyGravity(dt)
	self:applyCollisions(dt)
	self:applyWallVelocity()
    self:move(dt)
    self:checkWallJump()
end

function player:applyCollisions(dt)
	local futureX, futureY = self.x + (self.vx * dt), self.y + (self.vy * dt)
	local nextX, nextY, cols, len = world.bump:move(self, futureX, futureY)

	for i = 1, len do
		local col = cols[i]

		self:applyCollisionNormal(col.normal.x, col.normal.y)

		if col.normal.y == -1 then
			self.onGround = true
		end
	end

	self.x = nextX
	self.y = nextY
end

function player:applyWallVelocity()
	if (self.wallJumpRight or self.wallJumpLeft) and self.vy > 0 then
		self.vy = self.wallVelocity
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

		if item.shape == "rectangle" then
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