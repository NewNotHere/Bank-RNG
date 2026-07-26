const React = require("../../../Packages/React")
local e = React.createElement

type MobileButton = {
	Position: UDim2,
	Type: "Big" | "Small",
	Icon: string,
	ScaleRatio: number,
	Callback: () -> (),
}

return function(props)
	local rectOffset, setRectOffset = React.useState(Vector2.new(-1, 142))

	local size = React.useMemo(function()
		if props.Type == "Big" then
			return UDim2.fromOffset(160, 160)
		elseif props.Type == "Small" then
			return UDim2.fromOffset(100, 100)
		end

		return UDim2.fromOffset(0, 0)
	end, { props.Type })

	return e("ImageButton", {
		Image = "rbxassetid://78462064199829",
		ImageRectOffset = rectOffset,
		ImageRectSize = Vector2.new(144, 144),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = props.Position,
		Size = size,

		[React.Event.InputBegan] = function(_, input: InputObject)
			if input.UserInputState ~= Enum.UserInputState.Begin then
				return
			end

			setRectOffset(Vector2.new(142, 142))
		end,
		[React.Event.InputEnded] = function(_, input: InputObject)
			if input.UserInputState ~= Enum.UserInputState.End then
				return
			end

			setRectOffset(Vector2.new(-1, 142))
		end,
		[React.Event.Activated] = props.Callback,
	}, {
		Icon = e("ImageLabel", {
			Image = props.Icon,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(props.ScaleRatio, props.ScaleRatio),
			BackgroundTransparency = 1,
		}),
	})
end
