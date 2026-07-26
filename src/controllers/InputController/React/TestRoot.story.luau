const React = require("../../../Packages/React")
const ReactRoblox = require("../../../Packages/ReactRoblox")
const MobileButton = require("./MobileButton")
const MobileFrame = require("./MobileFrame")

local e = React.createElement

return function(target)
	local root = ReactRoblox.createRoot(target)
	root:render(e(MobileFrame, {}, {
		B1 = e(MobileButton, {
			Position = UDim2.fromScale(0, 0.4),
			Type = "Big",
			Icon = "rbxassetid://11560341824",
			ScaleRatio = 0.7,
			Callback = function()
				print("Activated!")
			end,
		}),
	}))

	return function()
		root:unmount()
	end
end
