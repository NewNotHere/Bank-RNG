const Players = game:GetService("Players")
const RunService = game:GetService("RunService")
const CameraController = require("@game/ReplicatedStorage/Controllers/CameraController")
const DataController = require("@game/ReplicatedStorage/Controllers/DataController")
const PlacementController = require("@game/ReplicatedStorage/Controllers/PlacementController")
const PlotController = require("@game/ReplicatedStorage/Controllers/PlotController")
const UIController = require("@game/ReplicatedStorage/Controllers/UIController")
const Camera = require("@game/ReplicatedStorage/Shared/Classes/Camera")

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
task.wait(5)
local plot = PlotController:getPlot()
if not plot then
	print(`im a gay little fag faggot bitch`)
	return
end

PlacementController:setPlotModel(plot)
PlacementController:start()

CameraController:switchCam(Camera.PlotCamera.new(plot))
