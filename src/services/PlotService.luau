const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Networker = require("@game/ReplicatedStorage/Packages/Networker")
const Signal = require("@game/ReplicatedStorage/Packages/Signal")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")
const ServerTypes = require("../ServerOnly/ServerTypes")
type PlotService = ServerTypes.PlotService
type Plot = ServerTypes.Plot

local PlotWall = ReplicatedStorage.Assets.Wall

local function checkPlotForPlayer(plot: Plot)
	return plot.Player ~= 0
end

local PlotService = {}

function PlotService.init(self: PlotService)
	self._trove = Trove.new() :: any
	self._allPlots = {}

	self.plotLoaded = Signal.new()
	self.networker = Networker.server.new("PlotService", self, {
		self.getPlayerPlot,
		self.getPlotAxis,
	})
end

function PlotService.start(self: PlotService)
	self:loadAllPlots()

	self._trove:Add(self.plotLoaded:Connect(function(player: Player, plot: ServerTypes.Plot)
		self.networker:fire(player, "plotLoaded", plot.Plot)
	end))
end

function PlotService.abort(self: PlotService)
	self._trove:Clean()
end

function PlotService.loadAllPlots(self: PlotService)
	local plotFolder = workspace.Plots

	for _, model in plotFolder:GetChildren() do
		model:SetAttribute("Owner", 0)
		table.insert(self._allPlots, {
			Player = 0,
			Plot = model,
			Spawn = model.PlotSpawn,
		})
	end
end

function PlotService.getPlayerPlot(self: PlotService, player: Player)
	for _, plot in self._allPlots do
		if plot.Player == player.UserId then
			return plot.Plot
		end
	end

	return nil
end

function PlotService.getPlotAxis(self: PlotService, player: Player)
	local plot = self:getPlayerPlot(player)

	if plot then
		local axis = plot:FindFirstChild("PlotAxis")

		if axis then
			local x = axis.X.Value
			local y = axis.Y.Value
			local z = axis.Z.Value

			return CFrame.fromMatrix(Vector3.zero, x, y, z)
		end
	end

	return nil
end

function PlotService.givePlotToPlayer(self: PlotService, player: Player)
	local _found = false

	for _, plot in self._allPlots do
		local hasPlayer = checkPlotForPlayer(plot)
		if hasPlayer then
			continue
		end

		plot.Player = player.UserId
		player.RespawnLocation = plot.Spawn
		plot.Plot:SetAttribute("Owner", plot.Player)
		self.plotLoaded:Fire(player, plot)
		_found = true

		break
	end

	if not _found then
		player:Kick(`No available plots! Try another server!`)
	end
end

function PlotService.removePlayerPlot(self: PlotService, player: Player)
	for _, plot in self._allPlots do
		if plot.Player == player.UserId then
			plot.Player = 0
			plot.Plot:SetAttribute("Owner", plot.Player)
		end
	end
end

function PlotService.createFloors(self: PlotService, player: Player, numFloors: number)
	local function createWall(n: number)
		local newWall = PlotWall:Clone()
		local plot = self:getPlayerPlot(player)

		if plot then
			local primary = plot.PrimaryPart
			if not primary then
				return
			end

			local _, bboxWall = newWall:GetBoundingBox()

			local newPos = CFrame.new(primary.Position + Vector3.new(0, 1, 0) + (Vector3.new(0, bboxWall.Y * n, 0)))

			newWall:PivotTo(newPos)
			newWall.Parent = plot.Walls
		end
	end

	for i = 0, numFloors - 1 do
		createWall(i)
	end
end

return PlotService :: PlotService
