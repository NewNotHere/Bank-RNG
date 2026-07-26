const CameraController = require("@game/ReplicatedStorage/Controllers/CameraController")
const DataController = require("@game/ReplicatedStorage/Controllers/DataController")
const PlacementController = require("@game/ReplicatedStorage/Controllers/PlacementController")
const PlotController = require("@game/ReplicatedStorage/Controllers/PlotController")
const UIController = require("@game/ReplicatedStorage/Controllers/UIController")

DataController:init()
PlotController:init()
PlacementController:init()
CameraController:init()
UIController:init()

DataController:start()
PlotController:start()
CameraController:start()
UIController:start()

DataController:waitForProfileLoaded():await()
local plot = PlotController:getPlot()
if not plot then
	error(`uh oh`)
	return
end

PlacementController:setPlotModel(plot)
PlacementController:start()
