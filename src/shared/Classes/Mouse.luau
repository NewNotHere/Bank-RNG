local UserInputService = game:GetService("UserInputService")
local ClientTypes = require("../ClientTypes")
local Mouse = {}
Mouse.__index = Mouse

function Mouse.new()
	local self = setmetatable({} :: ClientTypes.Mouse, Mouse)

	self._camera = workspace.CurrentCamera

	self:init()
	return self :: any
end

function Mouse.init(self: ClientTypes.Mouse) end

function Mouse.GetHit(self: ClientTypes.Mouse, raycastParams: RaycastParams?)
	local mousePos = UserInputService:GetMouseLocation()
	local ray = self._camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)

	return result
end

function Mouse.getMouseRay(self: ClientTypes.Mouse)
	local mousePos = UserInputService:GetMouseLocation()

	return self._camera:ViewportPointToRay(mousePos.X, mousePos.Y)
end

return Mouse
