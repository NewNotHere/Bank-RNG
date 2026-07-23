const Debris = game:GetService("Debris")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Networker = require("@game/ReplicatedStorage/Packages/Networker")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")
const ServerTypes = require("../ServerOnly/ServerTypes")
const PlotService = require("./PlotService")
type PlacementService = ServerTypes.PlacementService

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Placeables = Assets:WaitForChild("Placeables")

local function isAssetWithinPlot(plot: Model, cframe: CFrame, size: Vector3): boolean
	local bboxCFrame, bboxSize = plot:GetBoundingBox()

	local testPart = Instance.new("Part")
	testPart.Size = size
	testPart.CFrame = cframe
	testPart.Transparency = 1
	testPart.Parent = workspace.TryPlace
	Debris:AddItem(testPart, 1)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { testPart }

	local result = workspace:GetPartBoundsInBox(bboxCFrame, bboxSize + Vector3.new(0, 50, 0), overlapParams)

	if #result > 0 then
		return true
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

			if not isAssetWithinPlot(plot, cframe, bboxSize) then
				return
			end

			permanentAsset = permanentAsset:Clone()

			permanentAsset:PivotTo(cframe)
			permanentAsset.Parent = plot.Placed
		end
	end
end

return PlacementService :: PlacementService
