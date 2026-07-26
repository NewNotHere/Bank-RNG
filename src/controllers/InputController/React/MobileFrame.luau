const React = require("../../../Packages/React")
local e = React.createElement

local SMALL_SCREEN_THRESHOLD = 500
local SMALL_SCREEN_SCALE = 0.6

return function(props)
	local scale, setScale = React.useState(1)

	React.useEffect(function()
		local c = nil
		local currentCam = workspace.CurrentCamera

		c = currentCam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			local viewportSize = currentCam.ViewportSize
			local minAxis = math.min(viewportSize.X, viewportSize.Y)

			if minAxis <= SMALL_SCREEN_THRESHOLD then
				setScale(SMALL_SCREEN_SCALE)
			else
				setScale(1)
			end
		end)

		return function()
			c:Disconnect()
		end
	end, {})

	return e("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		Size = UDim2.fromOffset(280, 280),
		BackgroundTransparency = 1,
	}, {
		Scale = e("UIScale", {
			Scale = scale,
		}),
		Buttons = e(React.Fragment, nil, props.children),
	})
end
