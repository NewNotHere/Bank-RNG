const React = require("../../../Packages/React")
local e = React.createElement

return function(props)
	return e("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0.02, 0.98),
		Size = UDim2.fromScale(0.2, 0.175),
		BackgroundTransparency = 1,
	}, {
		List = e("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		Aspect = e("UIAspectRatioConstraint", {
			AspectRatio = 2,
		}),

		Text = e("TextLabel", {
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			TextScaled = true,
			FontFace = Font.fromId(11702779240, Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(65, 245, 41),
			Text = `$1,000,000`,
			ZIndex = 2,
		}, {
			Stroke = e("UIStroke", {
				Thickness = 3,
			}),
			Gradient = e("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 247, 56)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(33, 194, 33)),
				}),
				Offset = Vector2.new(0, 0.3),
				Rotation = 90,
			}),

			Text = e("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(0, 5),
				BackgroundTransparency = 1,
				TextScaled = true,
				FontFace = Font.fromId(11702779240, Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Text = `$1,000,000`,
				ZIndex = 1,
			}, {
				Stroke = e("UIStroke", {
					Thickness = 3,
				}),
			}),
		}),
	})
end
