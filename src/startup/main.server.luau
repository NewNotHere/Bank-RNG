const DataService = require("./Services/DataService")
const PlacementService = require("./Services/PlacementService")
const PlotService = require("./Services/PlotService")

DataService:init()
PlacementService:init()
PlotService:init()

DataService:start()
PlacementService:start()
PlotService:start()

DataService.dataLoaded:Connect(function(session)
	PlotService:givePlotToPlayer(session._player)

	PlotService:createFloors(session._player, session:get("Floors"))
end)

DataService.dataRemoved:Connect(function(session)
	PlotService:removePlayerPlot(session._player)
end)
