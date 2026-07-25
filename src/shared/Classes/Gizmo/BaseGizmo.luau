const ContextActionService = game:GetService("ContextActionService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserInputService = game:GetService("UserInputService")
const Signal = require("../../../Packages/Signal")
const Trove = require("../../../Packages/Trove")
const ClientTypes = require("../../ClientTypes")
const Mouse = require("../Mouse")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local GizmoModels = Assets:WaitForChild("Gizmos")

type Gizmos = "Translate" | "Rotate" | "Scale"
type Gizmo = ClientTypes.Gizmo<Gizmo>

local function getGizmoModelFromType(type: Gizmos): Model?
	local model = GizmoModels:FindFirstChild(`Gizmo_{type}`)

	if model then
		return model:Clone()
	end

	return nil
end

local function showGizmoHovering(part: BasePart): ()
	local adornment = part:FindFirstChildOfClass("BoxHandleAdornment")
	if not adornment then
		adornment = part:FindFirstChildOfClass("CylinderHandleAdornment")
	end

	if adornment then
		adornment.Transparency = 0
	end
end

local function showGizmoNotHovering(gizmoModel: Model): ()
	for _, adornment in gizmoModel:GetDescendants() do
		if adornment:IsA("BasePart") then
			continue
		end

		adornment.Transparency = 0.5
	end
end

local Gizmo = {}
Gizmo.__index = Gizmo

function Gizmo.new(type: Gizmos, camera: Camera)
	local self = setmetatable({} :: Gizmo, Gizmo)

	self._model = getGizmoModelFromType(type)
	assert(self._model, `Unable to find GizmoModel for type: {type}!`)

	self._trove = Trove.new()
	self._camera = camera
	self._mouse = Mouse.new()
	self._hoveringInstance = nil
	self._cframe = CFrame.identity
	self.cframeChanged = Signal.new()

	self._trove:Add(function()
		self._model:Destroy()
	end)

	self:init()
	return self
end

function Gizmo.init(self: Gizmo)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { self._model }
	local isDragging = false

	self._trove:BindToRenderStep(`GIZMO`, Enum.RenderPriority.Camera.Value, function(dt: number)
		local result = self._mouse:GetHit(raycastParams)
		local pos = Vector3.zero

		if not isDragging then
			if result then
				showGizmoHovering(result.Instance)
				self._hoveringInstance = result.Instance
				pos = result.Position
			else
				showGizmoNotHovering(self._model)
				self._hoveringInstance = nil
			end
		end

		local mouseDelta = UserInputService:GetMouseDelta()
		--mouse is locked
		if mouseDelta.Magnitude > 0 then
			self:onMoveAttempt(mouseDelta, dt, pos)
			self:updateGizmo()

			self.cframeChanged:Fire(self._cframe)
		end

		self:onUpdate(dt)
	end)

	ContextActionService:BindActionAtPriority(
		"Hold",
		function(_: string, inputState: Enum.UserInputState, _: InputObject)
			if inputState == Enum.UserInputState.Begin then
				-- Only grab the click when the cursor is over the gizmo; otherwise let it
				-- fall through to lower-priority actions (e.g. PlacementController's SELECT).
				if not self:getHovering() then
					return Enum.ContextActionResult.Pass
				end

				isDragging = true
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
				return Enum.ContextActionResult.Sink
			elseif inputState == Enum.UserInputState.End then
				if not isDragging then
					return Enum.ContextActionResult.Pass
				end

				isDragging = false
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				return Enum.ContextActionResult.Sink
			end

			return Enum.ContextActionResult.Pass
		end,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.UserInputType.MouseButton1
	)

	self._trove:Add(function()
		ContextActionService:UnbindAction("Hold")
	end)
end

--#region Abstract, overriden by child classes
function Gizmo.onCreated(self: Gizmo) end
function Gizmo.onUpdate(self: Gizmo, dt: number) end
function Gizmo.onMoveAttempt(self: Gizmo, moveDelta: Vector2, dt: number) end
function Gizmo.onDestroyed(self: Gizmo) end
--#endregion

function Gizmo.createGizmo(
	self: Gizmo,
	position: Vector3,
	lookVector: Vector3?,
	rightVector: Vector3?,
	upVector: Vector3?
)
	if lookVector and rightVector and upVector then
		self._cframe = CFrame.fromMatrix(position, rightVector, upVector, -lookVector)
	else
		self._cframe = CFrame.new(position)
	end

	self._model:PivotTo(self._cframe)
	self._model.Parent = self._camera

	self:onCreated()
end

function Gizmo.updateGizmo(self: Gizmo)
	self._model:PivotTo(self._cframe)
end

function Gizmo.getHovering(self: Gizmo)
	return self._hoveringInstance
end

function Gizmo.destroy(self: Gizmo)
	self:onDestroyed()
	self.cframeChanged:DisconnectAll()
	self._trove:Destroy()
end

return Gizmo
