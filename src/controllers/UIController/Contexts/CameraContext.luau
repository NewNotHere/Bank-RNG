const React = require("../../../Packages/React")
const Camera = require("../../../Shared/Classes/Camera")
local ClientTypes = require("../../../Shared/ClientTypes")
const CameraController = require("../../CameraController")
local PlacementController = require("../../PlacementController")
const PlotController = require("../../PlotController")

type CameraContext = {
	setBuildCamera: () -> (),
	setDefaultCamera: () -> (),
}

local context = React.createContext(nil :: CameraContext?)

local e = React.createElement

local function provider(props)
	local value = {
		setBuildCamera = function()
			local plotFocus = PlotController:getPlot()

			if plotFocus then
				CameraController:switchCam(Camera.PlotCamera.new(plotFocus))
			end
		end,

		setDefaultCamera = function()
			CameraController:switchCam(Camera.DefaultCamera.new())
		end,

		inspectWall = function()
			local camera = (CameraController:getActiveCamera() :: any) :: ClientTypes.PlotCamera
			local currentSelected = PlacementController:getSelected()

			if camera then
				camera:inspectWall(currentSelected)
			end
		end,

		stopWallInspection = function()
			local camera = (CameraController:getActiveCamera() :: any) :: ClientTypes.PlotCamera

			if camera then
				camera:stopWallInspection()
			end
		end,
	}

	return e(context.Provider, {
		value = value,
	}, props.children)
end

return {
	context = context,
	provider = provider,
}
