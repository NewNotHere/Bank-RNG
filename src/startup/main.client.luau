const Players = game:GetService("Players")
const CameraController = require("@game/ReplicatedStorage/Controllers/CameraController")
const PlacementController = require("@game/ReplicatedStorage/Controllers/PlacementController")
const PlotController = require("@game/ReplicatedStorage/Controllers/PlotController")
const UIController = require("@game/ReplicatedStorage/Controllers/UIController")
const Camera = require("@game/ReplicatedStorage/Shared/Classes/Camera")

PlotController:init()
PlacementController:init()
CameraController:init()
UIController:init()

PlotController:start()
CameraController:start()
UIController:start()

Players.LocalPlayer.CharacterAdded:Wait()
task.wait(5)
local plot = PlotController:getPlot()

PlacementController:setPlotModel(plot)
PlacementController:start()

--CameraController:switchCam(Camera.PlotCamera.new(plot))
