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
	SELECT = "Select",
	TRANSLATE = "Translate",
	ROTATE = "Rotate",
	SCALE = "Scale",
} :: {
	BUILD: string,
	SELECT: string,
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

local function createHighlight(parent: Instance): Highlight
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.Parent = parent

	return highlight
end

local function getHighlightFromModel(model: Model): Highlight?
	return model:FindFirstChildWhichIsA("Highlight", true)
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
	self._selected = nil

	self.placementStateChanged = Signal.new()

	self.networker = Networker.client.new("PlacementService", self)
end

function PlacementController.start(self: PlacementController) end

function PlacementController.abort(self: PlacementController)
	self._trove:Clean()
end
--#endregion

function PlacementController.getState(self: PlacementController)
	return self._state
end

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

function PlacementController.selectState(self: PlacementController)
	changeState(self, VALID_STATES.SELECT)

	self._trove:BindToRenderStep(VALID_STATES.SELECT, PRIORITY, function(dt: number)
		self:_hoverUpdate(dt)
	end)

	ContextActionService:BindAction(
		VALID_STATES.SELECT,
		function(_: string, inputState: Enum.UserInputState, _: InputObject)
			if inputState == Enum.UserInputState.End then
				local hit = self._mouse:GetHit()
				if hit then
					local model = hit.Instance:FindFirstAncestorOfClass("Model")
					if model == workspace then
						return
					end

					self:select(model)
				end
			end
		end,
		false,
		Enum.UserInputType.MouseButton1
	)

	self._trove:Add(function()
		ContextActionService:UnbindAction(VALID_STATES.SELECT)
	end)
end
--#endregion

--#region selection
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
			local highlight = createHighlight(Players.LocalPlayer.PlayerGui)
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

function PlacementController.getSelected(self: PlacementController)
	return self._selected
end

function PlacementController.select(self: PlacementController, modelToSelect: Model)
	if self._selected then
		local highlight = getHighlightFromModel(self._selected)

		if highlight then
			highlight:Destroy()
		end
	end

	local selectedHighlight = createHighlight(modelToSelect)
	self._selected = modelToSelect

	self._trove:Add(selectedHighlight)
	self._trove:Add(function()
		self._selected = nil
	end)
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
