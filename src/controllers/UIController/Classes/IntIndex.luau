const RunService = game:GetService("RunService")
const React = require("../../../Packages/React")
const TextLabel = require("./TextLabel")
local e = React.createElement

return function()
	local accum, setAccum = React.useState(0)

	React.useEffect(function()
		local c = nil
		local rotation = 0

		c = RunService.PreRender:Connect(function(dt: number)
			rotation = rotation + dt * 10
			setAccum(rotation)
		end)

		return function()
			c:Disconnect()
		end
	end, {})

	return e("Frame", {
		Size = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(70, 70, 70),
	}, {
		Aspect = e("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),
		Corner = e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		Image = e("ImageLabel", {
			Image = "rbxassetid://87503821706052",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1.3, 1.3),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = accum,
		}),
		Text = e(TextLabel, {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "0",
			TextColor3 = Color3.fromRGB(255, 255, 255),
		}),
	})
end
