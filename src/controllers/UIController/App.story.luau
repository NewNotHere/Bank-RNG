const React = require("../../Packages/React")
const ReactRoblox = require("../../Packages/ReactRoblox")
const App = require("./App")

const e = React.createElement

return function(target)
	local root = ReactRoblox.createRoot(target)
	local screenGui = target:FindFirstAncestorOfClass("ScreenGui") :: ScreenGui
	if screenGui then
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	end

	root:render(e(App))

	return function()
		root:unmount()
	end
end
