local world = require 'world'
local quads = require 'quads'
-- maps
local map_01 = require 'maps.map_01'
-- local map_02 = require 'maps.map_02'

-- environment tilesets
local tileset = love.graphics.newImage('tileset.png')
tileset:setFilter('nearest', 'nearest')
local tilesetQuads = quads:loadQuads(tileset, 1, 3)

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
		if self.currentMap.layers[i].type == "objectgroup" then
			local name = self.currentMap.layers[i].name
			local objects = self.currentMap.layers[i].objects
			if name == "Solids" then
				for j = #objects, 1, -1 do
					local solid = objects[j]
					solid.type = "solid"
					if solid.shape == "rectangle" then
						self.solids[#self.solids+1] = solid
						world.bump:add(solid, solid.x, solid.y, solid.width, solid.height)
					end
				end
			elseif name == "Spikes" then
				for j = #objects, 1, -1 do
					local solid = objects[j]
					solid.type = "spike"
					if solid.shape == "rectangle" then
						self.solids[#self.solids+1] = solid
						world.bump:add(solid, solid.x, solid.y, solid.width, solid.height)
					end
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
		if n == 1 then
			love.graphics.draw(tileset, tilesetQuads[1], x * tilewidth, y * tileheight)
		elseif n == 2 then
			love.graphics.draw(tileset, tilesetQuads[2], x * tilewidth, y * tileheight)
		elseif n == 3 then
			love.graphics.draw(tileset, tilesetQuads[3], x * tilewidth, y * tileheight)
		end
	end
end

return map