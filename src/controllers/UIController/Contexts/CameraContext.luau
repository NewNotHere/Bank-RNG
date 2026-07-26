const React = require("../../../Packages/React")
const Camera = require("../../../Shared/Classes/Camera")
const CameraController = require("../../CameraController")
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
	}

	return e(context.Provider, {
		value = value,
	}, props.children)
end

return {
	context = context,
	provider = provider,
}
