const HttpService = game:GetService("HttpService")
const Trove = require("../../../Packages/Trove")
const ClientTypes = require("../../ClientTypes")
type DefaultCamera = ClientTypes.DefaultCamera<DefaultCamera>

local DefaultCamera = {}
DefaultCamera.__index = DefaultCamera

function DefaultCamera.new()
	local self = setmetatable({} :: DefaultCamera, DefaultCamera)

	self._camera = workspace.CurrentCamera
	self._trove = Trove.new()
	self._cframe = self._camera.CFrame
	self._bindName = `Camera_{HttpService:GenerateGUID(false)}`

	self:init()
	return self :: any
end

function DefaultCamera.init(self: DefaultCamera)
	self._trove:BindToRenderStep(self._bindName, Enum.RenderPriority.Camera.Value, function(dt: number)
		self:update(dt)

		self._camera.CFrame = self._cframe
	end)
end

--Abstract, overriden in child classes
function DefaultCamera.enable(self: DefaultCamera)
	self._camera.CameraType = Enum.CameraType.Custom
end

function DefaultCamera.disable(self: DefaultCamera)
	self._trove:Clean()
end

--Abstract, overriden in child classes
function DefaultCamera.update(self: DefaultCamera)
	self._cframe = self._camera.CFrame
end

function DefaultCamera.getCFrame(self: DefaultCamera)
	return self._camera.CFrame
end

return DefaultCamera
