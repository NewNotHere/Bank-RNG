const React = require("../../../Packages/React")
const BuildButton = require("../Classes/BuildButton")
const PlacementContext = require("../Contexts/PlacementContext")
const e = React.createElement

local BUILD_BUTTONS = {
	"Build",
	"Translate",
	"Rotate",
}

local function buttons(fragmentProps)
	local _btns = {}

	for index, context in BUILD_BUTTONS do
		_btns[context] = e(BuildButton, {
			Key = index,
			Context = context,
			Activated = fragmentProps[context],
		})
	end

	return e(React.Fragment, nil, _btns)
end

return function()
	local placement = React.useContext(PlacementContext.context)

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.95),
		Size = UDim2.fromScale(0.5, 0.15),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(61, 61, 61),
		BackgroundTransparency = 0.2,
	}, {
		List = e("UIGridLayout", {
			CellPadding = UDim2.fromScale(0.05, 0),
			CellSize = UDim2.fromScale(0.8, 0.8),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {
			Aspect = e("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
		}),
		Buttons = e(buttons, {
			Build = function()
				print("Build")
				placement:setBuildMode()
			end,

			Translate = function()
				print("Translate")
				placement:setTranslateMode()
			end,

			Rotate = function()
				print("Rotate")
				placement:setRotateMode()
			end,
		}),
	})
end
