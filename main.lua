local map01 = require 'maps.map_01'
local solids = {}
local world = require 'world'
local timer = require 'timer'
local player = require 'player'
local map = require 'map'
local camera = require 'camera'

local cam = camera()

function love.load()
	world.load()
	player:load(64, 10, 32, 32)
	map:load()

	love.graphics.setBackgroundColor(205,205,205)
end

local printTimer = timer:new(1)
function love.update(dt)
	--[[
	printTimer:update(dt, function()
		print(collectgarbage('count'))
	end)
	--[[]]
	player:update(dt)
	cam:lookAt(player.x, player.y)
end

function love.draw()
	cam:attach()

	player:draw({255, 0, 0})
	love.graphics.setColor(255,255,255)
	map:draw()
	local fps = tostring(love.timer.getFPS())
	love.graphics.print(fps)

	cam:detach()
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end

	player:jump(key)
end