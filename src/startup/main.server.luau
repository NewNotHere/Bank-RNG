const Players = game:GetService("Players")
const PlacementService = require("./Services/PlacementService")
const PlotService = require("./Services/PlotService")

PlacementService:init()
PlotService:init()

PlacementService:start()
PlotService:start()

Players.PlayerAdded:Connect(function(player: Player)
	PlotService:givePlotToPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player: Player, _: Enum.PlayerExitReason)
	PlotService:removePlayerPlot(player)
end)
