const React = require("../../../Packages/React")
const useSpring = require("../Hooks/useSpring")
const e = React.createElement

type BuildButton = {
	Key: number,
	Context: string,
	Activated: () -> (),
}

return function(props: BuildButton)
	local spring = useSpring(1, 20, 0.5)

	return e("ImageButton", {
		Size = UDim2.fromScale(0.8, 0.8),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		LayoutOrder = props.Key,

		[React.Event.Activated] = function()
			props.Activated()
		end,

		[React.Event.MouseEnter] = function()
			spring.setTarget(1.1)
		end,
		[React.Event.MouseLeave] = function()
			spring.setTarget(1)
		end,
	}, {
		Aspect = e("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
		Scale = e("UIScale", {
			Scale = spring.position,
		}),
		Stroke = e("UIStroke", {
			Thickness = 2,
		}),

		Context = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.3),
			TextScaled = true,
			FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = props.Context,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			ZIndex = 2,
		}, {
			Stroke = e("UIStroke", {
				Thickness = 2,
			}),
		}),
		Index = e("TextLabel", {
			Size = UDim2.fromScale(0.2, 0.2),
			FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			TextScaled = true,
			Text = `{props.Key}`,
		}),

		Gradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(98, 1, 253)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(162, 0, 255)),
			}),
		}),

		Pattern = e("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://121480522",
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromScale(0.25, 0.25),
		}, {
			Gradient = e("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.3),
					NumberSequenceKeypoint.new(0.7, 1),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Rotation = -60,
			}),
		}),
	})
end
