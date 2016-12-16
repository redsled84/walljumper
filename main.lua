local map01 = require 'maps.map_01'
local solids = {}
local world = require 'world'
local timer = require 'timer'
local player = require 'player'
local map = require 'map'
local camera = require 'camera'
local disorient = require 'disorient'

local cam = camera()

function love.load()
	world.load()
	player:load(64, 64, 32, 32)
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
	local theta = disorient.getTheta()
	cam:lookAt(player.x, player.y)
end

function love.draw()
	cam:attach()

	disorient.disorient(.20, .20, .4)

	player:draw({255, 0, 0})
	love.graphics.setColor(255,255,255)
	map:drawTiles()
	local fps = tostring(love.timer.getFPS())
	love.graphics.print(fps)
	
	local items, len = world.bump:getItems()
	map:drawCoins(items, len)

	cam:detach()

	love.graphics.print(player.score, 10, 10)

	if player.dead then
		love.graphics.setColor(0,0,0)
		love.graphics.print("DEAD", love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	end
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end
	if key == 'r' then
		love.event.quit('restart')
	end

	player:jump(key)
end