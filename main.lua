local map01 = require 'maps.map_01'
local solids = {}
local world = require 'world'
local timer = require 'timer'
local player = require 'player'
local map = require 'map'

function love.load()
	world.load()
	player:load(64, 10, 32, 32)
	map:load()
end

local printTimer = timer:new(1)
function love.update(dt)
	--[[
	printTimer:update(dt, function()
		print(collectgarbage('count'))
	end)
	--[[]]
	player:update(dt)
end

function love.draw()
	player:draw({255, 0, 0})
	love.graphics.setColor(255,255,255)
	map:draw()
	local fps = tostring(love.timer.getFPS())
	love.graphics.print(fps)
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end

	player:jump(key)
end