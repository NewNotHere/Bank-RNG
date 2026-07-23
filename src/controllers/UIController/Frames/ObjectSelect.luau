const React = require("../../../Packages/React")
local e = React.createElement

return function(props)
	return e("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0.02, 0.5),
		Size = UDim2.fromScale(0.5, 0.55),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(66, 65, 65),
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
		Aspect = e("UIAspectRatioConstraint", {
			AspectRatio = 0.7,
		}),
		Stroke = e("UIStroke", {
			Thickness = 3,
		}),

		Image = e("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			Image = "rbxassetid://118369289564892",
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(500, 500),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
		}, {
			Gradient = e("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.75),
					NumberSequenceKeypoint.new(0.6, 1),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Rotation = -60,
			}),

			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
		}),
	})
end
