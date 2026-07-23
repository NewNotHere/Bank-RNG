const ClientTypes = require("../../ClientTypes")
const BaseGizmo = require("./BaseGizmo")

type Translate = ClientTypes.TranslateGizmo

local Translate = {}
Translate.__index = Translate
setmetatable(Translate, { __index = BaseGizmo })

function Translate.new(camera: Camera)
	local self = setmetatable(BaseGizmo.new("Translate", camera), Translate)

	self._xAxis = Vector3.xAxis
	self._yAxis = Vector3.yAxis
	self._zAxis = Vector3.zAxis
	self._grid = 1
	self._rawCFrame = CFrame.identity

	return self
end

function Translate.onCreated(self: Translate)
	self._rawCFrame = self._cframe
end

function Translate.onUpdate(self: Translate, dt: number) end

function Translate.onMoveAttempt(self: Translate, ...: any)
	local hovering = self:getHovering()
	if not hovering then
		return
	end

	if hovering.Name == "X" then
		self:moveX(...)
	elseif hovering.Name == "Y" then
		self:moveY(...)
	elseif hovering.Name == "Z" then
		self:moveZ(...)
	end

	local pos = self._rawCFrame.Position
	local snapped = Vector3.new(
		math.ceil(pos.X / self._grid) * self._grid,
		(math.ceil(pos.Y / self._grid) * self._grid) - 0.5,
		math.ceil(pos.Z / self._grid) * self._grid
	)

	self._cframe = CFrame.new(snapped) * self._rawCFrame.Rotation
end

function Translate.moveZ(self: Translate, moveDelta: Vector2, dt: number)
	local moveX = moveDelta.X
	local sign = self._rawCFrame.RightVector.X

	self._rawCFrame = self._rawCFrame + (self._zAxis * -moveX * sign) * dt
end

function Translate.moveY(self: Translate, moveDelta: Vector2, dt: number)
	local moveY = math.floor(moveDelta.Y / 1) * 1

	self._rawCFrame = self._rawCFrame + (self._yAxis * -moveY) * dt
end

function Translate.moveX(self: Translate, moveDelta: Vector2, dt: number)
	local moveZ = moveDelta.Y
	local sign = self._rawCFrame.RightVector.X

	self._rawCFrame = self._rawCFrame + (self._xAxis * moveZ * sign) * dt
end

return Translate
