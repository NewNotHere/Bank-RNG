const ContextActionService = game:GetService("ContextActionService")
const HttpService = game:GetService("HttpService")
const Players = game:GetService("Players")
const UserInputService = game:GetService("UserInputService")
const MobileStore = require("@self/MobileStore")
const MobileFrame = require("@self/React/MobileFrame")
const React = require("../Packages/React")
const ReactRoblox = require("../Packages/ReactRoblox")
const Signal = require("../Packages/Signal")
const Trove = require("../Packages/Trove")
const ClientTypes = require("../Shared/ClientTypes")

type InputController = ClientTypes.InputController

local defaultMap = {
	["Vector2"] = Vector2.zero,
	["number"] = 0,
}

local function getUUID()
	return HttpService:GenerateGUID(false)
end

local function getValueFromKey(self: InputController, key: Enum.KeyCode | Enum.UserInputType): (number | Vector2)?
	for _, map in self._mappings do
		local mapKey = map.Key

		if mapKey == key then
			return map.Value
		end
	end

	return nil
end

local function getValueTypeFromKey(self: InputController, key: Enum.KeyCode | Enum.UserInputType)
	local value = getValueFromKey(self, key)

	if value then
		return typeof(value)
	end

	return nil
end

local function getMobileGui(): ScreenGui
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local mobileGui = playerGui:FindFirstChild("Mobile")

	if not mobileGui then
		local mobileRoot = Instance.new("ScreenGui")
		mobileRoot.Name = "Mobile"
		mobileRoot.IgnoreGuiInset = true
		mobileRoot.ResetOnSpawn = false
		mobileRoot.Parent = playerGui

		mobileGui = mobileRoot
	end

	return mobileGui
end

local function getDefaultControls()
	local success, playerModule = pcall(function()
		return require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule") :: any)
	end)

	if success then
		return playerModule:GetControls()
	end

	error(`Error while trying to fetch PlayerModule! {playerModule}`)
end

local InputController = {}

function InputController.init(self: InputController)
	self._trove = Trove.new() :: any

	self._actions = {}

	self._mappings = {}
	self._values = {}
	self._inputType = Enum.PreferredInput.KeyboardAndMouse
	self._mobileButtons = {}
	self._defaultControls = nil

	self.deviceChanged = Signal.new()
end

function InputController.start(self: InputController)
	self._defaultControls = getDefaultControls()

	self._trove:Connect(UserInputService:GetPropertyChangedSignal("PreferredInput"), function(...): ...any
		local changedDeviceType = UserInputService.PreferredInput
		if changedDeviceType ~= self._inputType then
			self._inputType = changedDeviceType

			self.deviceChanged:Fire(self._inputType)
		end
	end)

	self._trove:Add(self.deviceChanged:Connect(function(input: Enum.PreferredInput)
		local gui = getMobileGui()

		if input == Enum.PreferredInput.Touch then
			gui.Enabled = true
		else
			gui.Enabled = false
		end
	end))

	local gui = getMobileGui()
	local root = ReactRoblox.createRoot(gui)
	root:render(React.createElement(MobileFrame))
end

function InputController.abort(self: InputController)
	self._trove:Clean()
end

function InputController.registerInputMap(self: InputController, inputMap: ClientTypes.InputMap)
	table.insert(self._mappings, inputMap)

	local function bind(_: string, state: Enum.UserInputState, _)
		if state == Enum.UserInputState.Begin then
			self._values[inputMap.Key] = inputMap.Value
		else
			self._values[inputMap.Key] = nil
		end
	end

	local uuid = getUUID()
	ContextActionService:BindAction(uuid, bind, false, inputMap.Key)
	table.insert(self._actions, uuid)

	self._trove:Add(function()
		ContextActionService:UnbindAction(uuid)
		table.remove(self._mappings, table.find(self._mappings, inputMap))
		self._values[inputMap.Key] = nil
	end)
end

function InputController.getInputValue(self: InputController, key: Enum.KeyCode | Enum.UserInputType)
	if self._values[key] then
		return self._values[key]
	end

	local foundType = getValueTypeFromKey(self, key)

	if foundType then
		return defaultMap[foundType]
	else
		warn(`{key.Name} is not registered!`)
	end

	return nil
end

function InputController.getDeviceInput(self: InputController)
	return self._inputType
end

function InputController.getInputAxis(self: InputController)
	if not self._defaultControls then
		return
	end

	if self._inputType == Enum.PreferredInput.KeyboardAndMouse then
		warn(`Keyboard Input cannot retrieve a continuous InputAxis`)
		return
	end

	local moveVector = self._defaultControls:GetMoveVector()
	local vector2Move = Vector2.new(moveVector.X, -moveVector.Z)

	if vector2Move.Magnitude == 0 then
		return vector2Move
	end

	return vector2Move.Unit
end

function InputController.addMobileButton(
	self: InputController,
	mobileButtonProps: ClientTypes.MobileButton,
	cb: (...any) -> (),
	...: any?
)
	local args = table.pack(...)

	local props = {
		Position = mobileButtonProps.Position or UDim2.fromScale(0, 0),
		Type = mobileButtonProps.Type or "Small",
		Icon = mobileButtonProps.Icon or "",
		ScaleRatio = mobileButtonProps.ScaleRatio or 1,
		Callback = function()
			if cb then
				cb(unpack(args, 1, args.n))
			end
		end,
	}
	local id = getUUID()
	MobileStore.add(id, props)
end

function InputController.removeMobileButtons(self: InputController, btnId: string)
	MobileStore.remove(btnId)
end

return InputController :: InputController
