const Players = game:GetService("Players")
const App = require("@self/App")
const React = require("../Packages/React")
const ReactRoblox = require("../Packages/ReactRoblox")
const Trove = require("../Packages/Trove")
const ClientTypes = require("../Shared/ClientTypes")
type UIController = ClientTypes.UIController

local function createContainer(): ScreenGui
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local screen = Instance.new("ScreenGui")
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screen.Name = "App"
	screen.Parent = playerGui

	return screen
end

local UIController = {}

function UIController.init(self: UIController)
	self._trove = Trove.new() :: any
end

function UIController.start(self: UIController)
	local root = ReactRoblox.createRoot(createContainer())
	root:render(React.createElement(App))

	self._trove:Add(function()
		root:unmount()
	end)
end

function UIController.abort(self: UIController)
	self._trove:Clean()
end

return UIController :: UIController
