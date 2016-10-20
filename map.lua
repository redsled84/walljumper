local world = require 'world'
-- maps
local map_01 = require 'maps.map_01'
-- local map_02 = require 'maps.map_02'

local map = {maps = {}, solids = {}, mapNumber = 0}

function map:load()
	self.mapNumber = self.mapNumber + 1

	self:loadMaps()
	self:loadSolids()
end

function map:loadMaps()
	if #self.maps == 0 then
		self.maps = {
			map_01,
			-- map_02
		}
	end
	self.currentMap = self.maps[self.mapNumber]
end

function map:loadSolids()
	-- remove pre-existing solids on load
	self:removeSolids()

	for i = #self.currentMap.layers, 1, -1 do
		if self.currentMap.layers[i].name == "Solids" then
			for j = #self.currentMap.layers[i].objects, 1, -1 do
				local solid = self.currentMap.layers[i].objects[j]
				print(solid.width)
				if solid.shape == "rectangle" then
					self.solids[#self.solids+1] = solid
					world.bump:add(solid, solid.x, solid.y, solid.width, solid.height)
				end
			end
		end
	end
end

function map:removeSolids()
	local len = #self.solids
	if len > 0 then
		for i = len, 1, -1 do
			world.bump:remove(self.solids[i])
		end
		for i = len, 1, -1 do
			table.remove(self.solids, i)
		end
	end
end

function map:draw()
	local width = self.currentMap.layers[1].width
	local height = self.currentMap.layers[1].height
	local tilewidth = self.currentMap.tilewidth
	local tileheight = self.currentMap.tileheight
	local x, y = 0, -1
	for i = 1, #self.currentMap.layers[1].data do
		local n = self.currentMap.layers[1].data[i]
		x = x + 1
		if (i-1) % width == 0 then
			y = y + 1
			x = 0
		end
		if n == 59 then
			love.graphics.rectangle("fill", x * tilewidth, y * tileheight, tilewidth, tileheight)
		end
	end
end

return map