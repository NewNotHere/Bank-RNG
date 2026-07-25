const React = require("../../../Packages/React")
const useSpring = require("../Hooks/useSpring")
const e = React.createElement

type BuildButton = {
	Key: number,
	Context: string,
	Image: string,
	Scale: number,
	Activated: () -> (),
}

return function(props: BuildButton)
	local spring = useSpring(props.Scale, 20, 0.5)

	return e("ImageButton", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = props.Key,
		Image = props.Image,

		[React.Event.Activated] = function()
			props.Activated()
		end,

		[React.Event.MouseEnter] = function()
			spring.setTarget(props.Scale + 0.1)
		end,
		[React.Event.MouseLeave] = function()
			spring.setTarget(props.Scale)
		end,
	}, {
		Aspect = e("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),
		Scale = e("UIScale", {
			Scale = spring.position,
		}),

		Text = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.95),
			Size = UDim2.fromScale(1, 0.2),
			TextScaled = true,
			BackgroundTransparency = 1,
			FontFace = Font.fromId(11702779240, Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = props.Context,
			ZIndex = 1,
		}, {
			Stroke = e("UIStroke", {
				Thickness = 3,
			}),
			BackText = e("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(0, 3),
				TextScaled = true,
				BackgroundTransparency = 1,
				FontFace = Font.fromId(11702779240, Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Text = props.Context,
				ZIndex = 0,
			}, {
				Stroke = e("UIStroke", {
					Thickness = 3,
				}),
			}),
		}),
	})
end
