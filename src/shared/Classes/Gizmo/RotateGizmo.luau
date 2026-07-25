const UserInputService = game:GetService("UserInputService")
const ClientTypes = require("../../ClientTypes")
const Mouse = require("../Mouse")
const BaseGizmo = require("./BaseGizmo")

type Rotate = ClientTypes.RotateGizmo

local Rotate = {}
Rotate.__index = Rotate
setmetatable(Rotate, { __index = BaseGizmo })

function Rotate.new(camera: Camera)
	local self = setmetatable(BaseGizmo.new("Rotate", camera), Rotate)

	self._xAxis = Vector3.xAxis
	self._yAxis = Vector3.yAxis
	self._zAxis = Vector3.zAxis
	self._grid = 10
	self._rawCFrame = CFrame.identity
	self._currentAngle = 0

	return self
end

function Rotate.onCreated(self: Rotate)
	self._rawCFrame = self._cframe
end

function Rotate.onUpdate(self: Rotate, dt: number) end

function Rotate.onMoveAttempt(self: Rotate, moveDelta: Vector2, dt: number, hitPosition: Vector3)
	local hovering = self:getHovering()

	if not hitPosition then
		return
	end

	if not hovering then
		return
	end

	local initialRotation = self._rawCFrame.Rotation
	local centre = self._rawCFrame.Position
	local axis = nil
	if hovering.Name == "X" then
		axis = self._zAxis
	elseif hovering.Name == "Y" then
		axis = self._yAxis
	elseif hovering.Name == "Z" then
		axis = self._xAxis
	else
		return
	end

	local worldAxis = initialRotation + axis
	local axisEnd = centre + worldAxis.Position

	local screenCentre = self._camera:WorldToScreenPoint(centre)
	local screenEnd = self._camera:WorldToScreenPoint(axisEnd)

	local screenAxis = (screenEnd - screenCentre).Unit
	local tangent = Vector2.new(-screenAxis.Y, screenAxis.X)
	local pixels = moveDelta:Dot(tangent)

	self._currentAngle += pixels * 0.1
	local angle = math.ceil(self._currentAngle / 5) * 5

	self._cframe = CFrame.new(self._cframe.Position) * CFrame.fromAxisAngle(axis, math.rad(angle))
end

function Rotate.onDestroyed(self: Rotate) end

return Rotate
