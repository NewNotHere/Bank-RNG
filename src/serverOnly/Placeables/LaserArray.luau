local ServerTypes = require("../ServerTypes")
local Base = require("./Base")

type LaserArray = ServerTypes.LaserArray

local ON_TIME = 2
local OFF_TIME = 2

local LaserArray = {}
LaserArray.__index = LaserArray
setmetatable(LaserArray, { __index = Base })

function LaserArray.new(model: Model)
	local self = setmetatable(Base.new(model), LaserArray)

	task.spawn(function()
		self:init()
	end)
	return self
end

function LaserArray.setVisible(self: LaserArray, visible: boolean)
	for _, part in self._model:GetDescendants() do
		if part.Name ~= "Laser" or not part:IsA("BasePart") then
			continue
		end

		part.Transparency = if visible then 0 else 1
	end
end

function LaserArray.init(self: LaserArray)
	local running = true
	self._trove:Add(function()
		running = false
	end)

	while running do
		self:setVisible(false)
		task.wait(OFF_TIME)

		self:setVisible(true)
		task.wait(ON_TIME)
	end
end

function LaserArray.update(self: LaserArray, dt: number) end

return LaserArray
