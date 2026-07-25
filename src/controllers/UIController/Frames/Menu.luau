const React = require("../../../Packages/React")
const BuildButton = require("../Classes/BuildButton")
const PlacementContext = require("../Contexts/PlacementContext")
const UIStateContext = require("../Contexts/UIStateContext")
const useSpring = require("../Hooks/useSpring")
const e = React.createElement

local MENU_BUTTONS = {
	{ "Build", "rbxassetid://72304759532069", 1 },
	{ "Manage", "rbxassetid://112110638677903", 1.1 },
	{ "Steal", "rbxassetid://122787461673356", 1 },
}

local function buttons(fragmentProps)
	local _btns = {}

	for index, data in MENU_BUTTONS do
		local context = data[1]
		local image = data[2]
		local scale = data[3]

		_btns[context] = e(BuildButton, {
			Key = index,
			Context = context,
			Image = image,
			Scale = scale,
			Activated = fragmentProps[context],
		})
	end

	return e(React.Fragment, nil, _btns)
end

return function()
	local context = React.useContext(UIStateContext.context)
	local placementContext = React.useContext(PlacementContext.context)
	local spring = useSpring(Vector2.new(0.5, 1.5), 10, 0.7)

	React.useEffect(function()
		if context.state == "Menu" then
			spring.setTarget(Vector2.new(0.5, 0.95))
		else
			spring.setTarget(Vector2.new(0.5, 1.5))
		end
	end, { context.state })

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(spring.position.X, spring.position.Y),
		Size = UDim2.fromScale(0.5, 0.15),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(61, 61, 61),
		BackgroundTransparency = 1,
	}, {
		List = e("UIGridLayout", {
			CellPadding = UDim2.fromScale(0, 0),
			CellSize = UDim2.fromScale(1.1, 1.1),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {
			Aspect = e("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
		}),
		Buttons = e(buttons, {
			Build = function()
				context.setState("Build")
				placementContext.setBuildMode()
			end,

			Manage = function() end,

			Steal = function() end,
		}),
	})
end
