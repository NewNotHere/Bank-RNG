local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
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

local InputController = {}

function InputController.init(self: InputController)
	self._trove = Trove.new() :: any

	self._actions = {}

	self._mappings = {}
	self._values = {}
	self._inputType = Enum.PreferredInput.KeyboardAndMouse
end

function InputController.start(self: InputController)
	self._trove:Connect(UserInputService:GetPropertyChangedSignal("PreferredInput"), function(...): ...any
		self._inputType = UserInputService.PreferredInput
	end)
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

return InputController
