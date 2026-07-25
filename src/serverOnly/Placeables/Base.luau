const RunService = game:GetService("RunService")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")
const ServerTypes = require("../ServerTypes")

type BaseAsset = ServerTypes.BaseAsset<BaseAsset>

local base = {}
base.__index = base

function base.new(model: Model)
	local self = setmetatable({}, base)

	self._model = model
	self._trove = Trove.new()

	self:init()
	return self
end

function base.init(self: BaseAsset)
	self._trove:Connect(RunService.Heartbeat, function(dt: number)
		self:update(dt)
	end)
end

function base.update(self: BaseAsset, dt: number) end

function base.destroy(self: BaseAsset)
	self._trove:Destroy()
end

return base
