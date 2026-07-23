const Camera = require("../Shared/Classes/Camera")
const ClientTypes = require("../Shared/ClientTypes")
type CameraController = ClientTypes.CameraController

local CameraController = {}

function CameraController.init(self: CameraController)
	self.camera = Camera.DefaultCamera.new()
end

function CameraController.start(self: CameraController)
	self.camera:enable()
end

function CameraController.abort(self: CameraController) end

function CameraController.switchCam(self: CameraController, newCam: ClientTypes.DefaultCamera<{}>)
	self.camera:disable()

	self.camera = newCam
	self.camera:enable()
end

function CameraController.getCamera(self: CameraController)
	return self.camera._camera
end

return CameraController :: CameraController
