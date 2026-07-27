const ContextActionService = game:GetService("ContextActionService")
const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Networker = require("../Packages/Networker")
const Signal = require("../Packages/Signal")
const Trove = require("../Packages/Trove")
const Gizmo = require("../Shared/Classes/Gizmo")
const Mouse = require("../Shared/Classes/Mouse")
const ClientTypes = require("../Shared/ClientTypes")
const Modules = require("../Shared/Modules")
const CameraController = require("./CameraController")
const PlotController = require("./PlotController")

type PlacementController = ClientTypes.PlacementController

local VALID_STATES = {
	BUILD = "Build",
	TRANSLATE = "Translate",
	ROTATE = "Rotate",
	SCALE = "Scale",
} :: {
	BUILD: string,
	TRANSLATE: string,
	ROTATE: string,
	SCALE: string,
}

local PRIORITY = Enum.RenderPriority.Character.Value

local CELL = 1

local function snapToGrid(value: number, halfExtent: number): number
	local offset = halfExtent % CELL
	return math.floor((value - offset) / CELL) * CELL + offset
end

local function getSnappedPivot(self: PlacementController): CFrame?
	local plot = self._plotModel
	local model = self._placing
	if not plot or not model then
		return nil
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { plot.PrimaryPart }

	local hit = self._mouse:GetHit(raycastParams)
	if not hit or hit.Normal.Unit ~= Vector3.yAxis then
		return nil
	end

	local bboxCFrame, bboxSize = model:GetBoundingBox()

	-- Preserve the current rotation (e.g. from the R key) instead of resetting it.
	local rotation = model:GetPivot().Rotation

	-- The bounding box (center + size), not the pivot, is what tiles the grid.
	local half = bboxSize / 2

	-- Snap relative to the plot's own origin (not the world origin) so the
	-- grid lines up with the plot even when it's offset or rotated.
	local plotCFrame = plot:GetPivot()

	-- Footprint half-extents along the plot's X/Z axes (AABB of the possibly
	-- rotated box), so a rotated wall still tiles cleanly.
	local rel = plotCFrame:ToObjectSpace(bboxCFrame)
	local footX = math.abs(rel.XVector.X) * half.X + math.abs(rel.YVector.X) * half.Y + math.abs(rel.ZVector.X) * half.Z
	local footZ = math.abs(rel.XVector.Z) * half.X + math.abs(rel.YVector.Z) * half.Y + math.abs(rel.ZVector.Z) * half.Z

	local localHit = plotCFrame:PointToObjectSpace(hit.Position)
	local snappedX = snapToGrid(localHit.X, footX)
	local snappedZ = snapToGrid(localHit.Z, footZ)
	-- Rest the box's bottom face on the surface (center = surface + halfHeight).
	local localCenter = Vector3.new(snappedX, localHit.Y + half.Y, snappedZ)

	-- Where the bounding-box center should end up, in world space.
	local targetCenter = CFrame.new((plotCFrame * CFrame.new(localCenter)).Position) * rotation

	-- Back out the pivot so the center lands on target regardless of pivot offset.
	local pivotToCenter = model:GetPivot():ToObjectSpace(bboxCFrame)

	return targetCenter * pivotToCenter:Inverse()
end

local function isStateValid(state: string): boolean
	for _, stateValue in VALID_STATES do
		if stateValue == state then
			return true
		end
	end

	return false
end

local function changeState(self: PlacementController, newState: string)
	if isStateValid(newState) then
		if self._state == newState then
			return
		end

		self._state = newState
		self._trove:Clean()

		self.placementStateChanged:Fire(newState)
	end
end

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Placeables = Assets:WaitForChild("Placeables")

local PlacementController = {}

--#region Lifecycle
function PlacementController.init(self: PlacementController)
	self._trove = Trove.new() :: any
	self._mouse = Mouse.new()
	self._plotModel = nil
	self._placing = nil
	self._state = "Build"
	self._highlight = nil

	self.placementStateChanged = Signal.new()

	self.networker = Networker.client.new("PlacementService", self)
end

function PlacementController.start(self: PlacementController) end

function PlacementController.abort(self: PlacementController)
	self._trove:Clean()
end
--#endregion

--#region State handling
function PlacementController.buildingState(self: PlacementController)
	changeState(self, VALID_STATES.BUILD)

	self._placing = Placeables:WaitForChild("Wall"):Clone()
	self:setPlacementVisual(self._placing :: Model)

	self._trove:BindToRenderStep(VALID_STATES.BUILD, PRIORITY, function(dt: number)
		self:_buildUpdate(dt)
	end)

	ContextActionService:BindAction(
		VALID_STATES.BUILD,
		function(_: string, inputState: Enum.UserInputState, _: InputObject)
			if inputState == Enum.UserInputState.End then
				self:tryPlace()
			end
		end,
		false,
		Enum.UserInputType.MouseButton1
	)

	ContextActionService:BindAction("Rotate", function(_: string, inputState: Enum.UserInputState, _: InputObject)
		if inputState ~= Enum.UserInputState.End then
			return
		end

		if self._placing then
			self._placing:PivotTo(self._placing:GetPivot() * CFrame.Angles(0, math.pi / 2, 0))
		end
	end, false, Enum.KeyCode.R)

	self._trove:Add(function()
		ContextActionService:UnbindAction(VALID_STATES.BUILD)
		ContextActionService:UnbindAction("Rotate")

		if self._placing then
			self._placing:Destroy()
			self._placing = nil
		end
	end)
end

function PlacementController._buildUpdate(self: PlacementController, dt: number)
	local model = self._placing
	local targetPivot = getSnappedPivot(self)

	if model and targetPivot then
		local bboxCFrame, bboxSize = model:GetBoundingBox()
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = { model }

		local numPartsInside =
			workspace:GetPartBoundsInBox(bboxCFrame, bboxSize - Vector3.new(0.1, 0.1, 0.1), overlapParams)
		if #numPartsInside > 0 then
			Modules.ApplyForcefield(model, Color3.fromRGB(231, 24, 24))
		else
			Modules.ApplyForcefield(model)
		end

		model:PivotTo(model:GetPivot():Lerp(targetPivot, dt * 10))
	end
end

function PlacementController._getPlotFacing(self: PlacementController): Vector3
	local plot = self._plotModel
	if not plot then
		return Vector3.zAxis
	end

	local plotSpawn = plot:FindFirstChild("PlotSpawn") :: BasePart?
	local dir: Vector3
	if plotSpawn then
		dir = plotSpawn.CFrame.LookVector
	else
		dir = plot:GetPivot().LookVector
	end

	local flat = Vector3.new(dir.X, 0, dir.Z)

	return flat.Unit
end

function PlacementController.translateState(self: PlacementController)
	changeState(self, VALID_STATES.TRANSLATE)
	local gizmo = Gizmo.Translate.new(CameraController:getCamera())

	self._trove:BindToRenderStep(VALID_STATES.TRANSLATE, PRIORITY, function(dt: number)
		self:_hoverUpdate(dt)
	end)

	local selected: Model? = nil
	local selectedRotation = CFrame.identity
	gizmo.cframeChanged:Connect(function(newCFrame: CFrame)
		if selected then
			selected:PivotTo(CFrame.new(newCFrame.Position) * selectedRotation)
		end
	end)

	ContextActionService:BindAction("SELECT", function(_: string, inputState: Enum.UserInputState, _: InputObject)
		if inputState ~= Enum.UserInputState.End then
			return
		end

		local highlight = self._highlight
		if not highlight then
			return
		end

		if not highlight.Adornee then
			return
		end
		selected = highlight.Adornee

		if selected then
			local pivot = selected:GetPivot()
			selectedRotation = pivot.Rotation

			local axis = PlotController:getPlotAxis()
			gizmo:createGizmo(pivot.Position, axis.LookVector, axis.RightVector, axis.UpVector)
		end
	end, false, Enum.UserInputType.MouseButton1)

	self._trove:Add(function()
		ContextActionService:UnbindAction("SELECT")
		gizmo:destroy()

		if self._highlight then
			self._highlight:Destroy()
			self._highlight = nil
		end
	end)
end

function PlacementController.rotateState(self: PlacementController)
	changeState(self, VALID_STATES.ROTATE)
	local gizmo = Gizmo.Rotate.new(CameraController:getCamera())

	self._trove:BindToRenderStep(VALID_STATES.ROTATE, PRIORITY, function(dt: number)
		self:_hoverUpdate(dt)
	end)

	local selected: Model? = nil
	gizmo.cframeChanged:Connect(function(cframe: CFrame)
		if selected then
			selected:PivotTo(cframe)
		end
	end)

	ContextActionService:BindAction("SELECT", function(_: string, inputState: Enum.UserInputState, _: InputObject)
		if inputState ~= Enum.UserInputState.End then
			return
		end

		local highlight = self._highlight
		if not highlight then
			return
		end

		if not highlight.Adornee then
			return
		end
		selected = highlight.Adornee

		if selected then
			gizmo:createGizmo(selected:GetPivot().Position)
		end
	end, false, Enum.UserInputType.MouseButton1)

	self._trove:Add(function()
		ContextActionService:UnbindAction("SELECT")
		gizmo:destroy()

		if self._highlight then
			self._highlight:Destroy()
			self._highlight = nil
		end
	end)
end

function PlacementController.scaleState(self: PlacementController)
	changeState(self, VALID_STATES.SCALE)

	self._trove:BindToRenderStep(VALID_STATES.SCALE, PRIORITY, function(dt: number)
		self:_hoverUpdate(dt)
	end)
end

function PlacementController._hoverUpdate(self: PlacementController, dt: number)
	if not self._plotModel then
		return
	end

	local placed = self._plotModel:FindFirstChild("Placed")

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { placed }

	local hit = self._mouse:GetHit(raycastParams)
	if hit then
		if not self._highlight then
			local highlight = Instance.new("Highlight")
			highlight.Parent = Players.LocalPlayer.PlayerGui
			highlight.FillTransparency = 1
			self._trove:Add(highlight)

			self._highlight = highlight
		end

		local highlight = self._highlight :: Highlight

		local model = hit.Instance:FindFirstAncestorOfClass("Model")

		if model then
			highlight.Adornee = model
		end
	else
		if self._highlight then
			self._highlight.Adornee = nil
		end
	end
end
--#endregion

--#region Building
function PlacementController.setPlotModel(self: PlacementController, model: Model)
	self._plotModel = model
end

function PlacementController.setPlacementVisual(self: PlacementController, model: Model)
	Modules.ApplyForcefield(model)

	for _, part in model:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Transparency = 0.5
		part.CanCollide = false
	end
	model.Parent = workspace
end

function PlacementController.setPlacementModel(self: PlacementController, modelName: string)
	local model = Placeables:FindFirstChild(modelName)

	if model then
		if self._placing then
			self._placing:Destroy()

			self._placing = nil
		end

		self._placing = model:Clone()
		self:setPlacementVisual(self._placing :: Model)
	else
		warn(`{modelName} is not a valid Placeable!`)
	end
end

function PlacementController.getPlacementModel(self: PlacementController)
	return self._placing
end

function PlacementController.tryPlace(self: PlacementController)
	local model = self._placing
	if not model then
		return
	end

	local snappedCFrame = getSnappedPivot(self)
	if not snappedCFrame then
		return
	end

	model:PivotTo(snappedCFrame)

	self.networker:fire("tryPlace", model.Name, snappedCFrame)
end
--#endregion

return PlacementController :: PlacementController
