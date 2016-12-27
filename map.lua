local world = require 'world'
local quads = require 'quads'
-- maps
local map_01 = require 'maps.map_04'
-- local map_02 = require 'maps.map_02'

-- environment tilesets
local tileset = love.graphics.newImage('tileset.png')
tileset:setFilter('nearest', 'nearest', 0)
local tilesetQuads = quads:loadQuads(tileset, 1, 4)

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
					solid.name = "solid"
					if solid.shape == "rectangle" then
						self.solids[#self.solids+1] = solid
						world.bump:add(solid, solid.x, solid.y, solid.width, solid.height)
					end
				end
			elseif name == "Spikes" then
				for j = #objects, 1, -1 do
					local solid = objects[j]
					solid.name = "spike"
					if solid.shape == "rectangle" then
						self.solids[#self.solids+1] = solid
						world.bump:add(solid, solid.x, solid.y, solid.width, solid.height)
					end
				end
			elseif name == "Coins" then
				for j = #objects, 1, -1 do
					local solid = objects[j]
					solid.name = "coin"
					if solid.shape == "rectangle" then
						if solid.height == 0 then
							solid.height = self.currentMap.height
						end
						-- generate individual coins from a large object
						if solid.height > self.currentMap.tileheight or solid.width > self.currentMap.tilewidth then
							local tileshigh = solid.height / self.currentMap.tileheight
							local tileswide = solid.width / self.currentMap.tilewidth
							local x, y = 0, 0
							for j = 1, tileshigh do
								y = (j - 1) * self.currentMap.tileheight + solid.y
								for i = 1, tileswide do
									x = (i - 1) * self.currentMap.tilewidth + solid.x
									local coin = {
										x = x,
										y = y,
										width = self.currentMap.tilewidth,
										height = self.currentMap.tileheight,
										name = "coin",
										shape = "rectangle"
									}
									self.solids[#self.solids+1] = coin
									world.bump:add(coin, coin.x, coin.y, coin.width, coin.height)
								end
							end
						end
						if solid.height == self.currentMap.tileheight and solid.width == self.currentMap.tilewidth then
							self.solids[#self.solids+1] = solid
							world.bump:add(solid, solid.x, solid.y, solid.width, solid.height)
						end
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

function map:drawTiles()
	-- TODO: select foreground layer and background layer (in the future)
	-- tiles
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
		love.graphics.setColor(255,255,255)
		if n == 1 then
			love.graphics.draw(tileset, tilesetQuads[1], x * tilewidth, y * tileheight)
		elseif n == 2 then
			love.graphics.draw(tileset, tilesetQuads[2], x * tilewidth, y * tileheight)
		elseif n == 3 then
			love.graphics.draw(tileset, tilesetQuads[3], x * tilewidth, y * tileheight)
		end
	end
end

function map:drawWorldObjects()
	-- objects
	for i = 1, #self.currentMap.layers do
		local name = self.currentMap.layers[i].name
		if name == "Solids" or name == "Spikes" then
			for j = 1, #self.currentMap.layers[i].objects do
				local object = self.currentMap.layers[i].objects[j]
				love.graphics.setColor(0,0,0)
				love.graphics.print(object.type, object.x, object.y)
				love.graphics.rectangle("line", object.x, object.y, object.width, object.height)
			end
		end
	end
end

function map:drawCoins(items, len)
	for i = 1, len do
		local item = items[i]
		if item.name == "coin" then
			love.graphics.setColor(255,255,255)
			love.graphics.draw(tileset, tilesetQuads[4], item.x, item.y)
		end
	end
end

return map