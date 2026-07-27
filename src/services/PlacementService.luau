const Debris = game:GetService("Debris")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Networker = require("@game/ReplicatedStorage/Packages/Networker")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")
const PlaceablesClass = require("../ServerOnly/Placeables")
const ServerTypes = require("../ServerOnly/ServerTypes")
const PlotService = require("./PlotService")
type PlacementService = ServerTypes.PlacementService

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Placeables = Assets:WaitForChild("Placeables")

local function canPlace(cframe: CFrame, size: Vector3): boolean
	local result = workspace:GetPartBoundsInBox(cframe, size - Vector3.new(0.1, 0.1, 0.1))

	if #result > 0 then
		return false
	end

	return true
end

local PlacementService = {}

function PlacementService.init(self: PlacementService)
	self._trove = Trove.new() :: any
	self.networker = Networker.server.new("PlacementService", self, {
		self.tryPlace,
	})
end

function PlacementService.start(self: PlacementService) end

function PlacementService.abort(self: PlacementService)
	self._trove:Clean()
end

function PlacementService.tryPlace(self: PlacementService, player: Player, assetName: string, cframe: CFrame)
	local plot = PlotService:getPlayerPlot(player)

	if plot then
		local permanentAsset: Model = Placeables:FindFirstChild(assetName)

		if permanentAsset then
			local _, bboxSize = permanentAsset:GetBoundingBox()

			if not canPlace(cframe, bboxSize) then
				return
			end

			permanentAsset = permanentAsset:Clone()

			permanentAsset:PivotTo(cframe)
			permanentAsset.Parent = plot.Placed

			local class = PlaceablesClass[permanentAsset.Name]
			if class then
				class.new(permanentAsset)
			end
		end
	end
end

return PlacementService :: PlacementService
