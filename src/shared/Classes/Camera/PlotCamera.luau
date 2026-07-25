const ContextActionService = game:GetService("ContextActionService")
const UserInputService = game:GetService("UserInputService")
const ClientTypes = require("../../ClientTypes")
const DefaultCamera = require("./DefaultCamera")

type PlotCamera = ClientTypes.PlotCamera

local PlotCamera = {}
PlotCamera.__index = PlotCamera
setmetatable(PlotCamera, { __index = DefaultCamera })

function PlotCamera.new(plotFocus: Model)
	local self = setmetatable(DefaultCamera.new() :: PlotCamera, PlotCamera)

	self._plot = plotFocus
	self._xOffset = 0
	self._zOffset = 0

	return self
end

function PlotCamera.enable(self: PlotCamera)
	self._camera.CameraType = Enum.CameraType.Scriptable

	self._trove:Add(function() end)
end

function PlotCamera.update(self: PlotCamera, dt: number)
	local plotSpawn = self._plot:FindFirstChild("PlotSpawn")

	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		self:moveX(-1)
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		self:moveX(1)
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		self:moveZ(1)
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		self:moveZ(-1)
	end

	local plotCFrame = self._plot:GetPivot()
	local _, bboxSize = self._plot:GetBoundingBox()
	local originCFrame =
		CFrame.new(plotCFrame.Position + Vector3.new(0, 20, bboxSize.Z), self._plot:GetPivot().Position)

	local cf = self:getCFrame()
	local flatLook = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
	local flatRight = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
	local offsetCFrame = (flatLook * self._zOffset) + (flatRight * self._xOffset)

	self._cframe = self._cframe:Lerp(originCFrame + offsetCFrame, dt)
end

function PlotCamera.moveX(self: PlotCamera, direction: number)
	self._xOffset += direction
end
function PlotCamera.moveZ(self: PlotCamera, direction: number)
	self._zOffset += direction
end

return PlotCamera
