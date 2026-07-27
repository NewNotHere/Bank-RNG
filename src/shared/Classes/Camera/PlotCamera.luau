const UserInputService = game:GetService("UserInputService")
const ClientTypes = require("../../ClientTypes")
const DefaultCamera = require("./DefaultCamera")

type PlotCamera = ClientTypes.PlotCamera

local function freeMovement(self: PlotCamera, dt: number)
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
	local originCFrame = CFrame.new(plotCFrame.Position + Vector3.new(0, 50, 0), plotCFrame.Position)

	local cf = self:getCFrame()
	local flatLook = Vector3.new(cf.UpVector.X, 0, cf.UpVector.Z).Unit
	local flatRight = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit

	local halfX = bboxSize.X / 2
	local halfZ = bboxSize.Z / 2

	self._xOffset = math.clamp(self._xOffset, -halfX, halfX)
	self._zOffset = math.clamp(self._zOffset, -halfZ, halfZ)

	local offsetCFrame = (flatLook * self._zOffset) + (flatRight * self._xOffset)

	self._cframe = self._cframe:Lerp(originCFrame + offsetCFrame, dt * 2)
end

local function inspection(self: PlotCamera, dt: number)
	local wallModel = self._inspecting :: Model
	local wallCframe = wallModel:GetPivot()
	local goalCframe = wallCframe * CFrame.new(wallCframe.LookVector * -5)

	self._cframe = self._cframe:Lerp(CFrame.new(goalCframe.Position, goalCframe.Position + wallCframe.Position), dt)
end

local PlotCamera = {}
PlotCamera.__index = PlotCamera
setmetatable(PlotCamera, { __index = DefaultCamera })

function PlotCamera.new(plotFocus: Model)
	local self = setmetatable(DefaultCamera.new() :: PlotCamera, PlotCamera)

	self._plot = plotFocus
	self._xOffset = 0
	self._zOffset = 0
	self._inspecting = nil

	return self
end

function PlotCamera.enable(self: PlotCamera)
	self._camera.CameraType = Enum.CameraType.Scriptable
end

function PlotCamera.update(self: PlotCamera, dt: number)
	if self._inspecting then
		inspection(self, dt)
	else
		freeMovement(self, dt)
	end
end

function PlotCamera.moveX(self: PlotCamera, direction: number)
	self._xOffset += direction
	print(self._xOffset, self._zOffset)
end
function PlotCamera.moveZ(self: PlotCamera, direction: number)
	self._zOffset += direction
	print(self._xOffset, self._zOffset)
end

function PlotCamera.inspectWall(self: PlotCamera, wallModel: Model)
	self._inspecting = wallModel
end

function PlotCamera.stopWallInspection(self: PlotCamera)
	self._inspecting = nil
end

return PlotCamera
