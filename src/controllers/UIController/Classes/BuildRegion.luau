const React = require("../../../Packages/React")
const PlacementContext = require("../Contexts/PlacementContext")
const useSpring = require("../Hooks/useSpring")
const TextButton = require("./TextButton")
const TextLabel = require("./TextLabel")
local e = React.createElement

type BuildingRegion = {
	Text: string,
	Assets: { string },
}

type ChildAssetComp = {
	Assets: { string },
}

local function btn(props)
	local context = React.useContext(PlacementContext.context)
	local spring = useSpring(1, 20, 0.7)

	return e(TextButton, {
		Text = props.Text,
		TextColor3 = Color3.fromRGB(255, 255, 255),

		[React.Event.Activated] = function()
			print("Switched!")
			context.setPlacementModel(props.Text)
		end,

		[React.Event.MouseEnter] = function()
			spring.setTarget(1.1)
		end,

		[React.Event.MouseLeave] = function()
			spring.setTarget(1)
		end,
	}, {
		Scale = e("UIScale", {
			Scale = spring.position,
		}),
	})
end

local function childAssets(props: ChildAssetComp)
	local assets = {}

	for i, text in props.Assets do
		assets[i] = e(btn, {
			Text = text,
		})
	end

	return e(React.Fragment, nil, assets)
end

return function(props: BuildingRegion)
	return e("Frame", {
		Size = UDim2.fromScale(1, 0.2),
		BackgroundTransparency = 1,
	}, {
		UIList = e("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Text = e(TextLabel, {
			Size = UDim2.fromScale(1, 0.2),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = props.Text,
			TextYAlignment = Enum.TextYAlignment.Top,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
		}, {
			Stroke = e("UIStroke", {
				Thickness = 3,
			}),
		}),
		Content = e("Frame", {
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0.7),
			BackgroundTransparency = 1,
		}, {
			UIGrid = e("UIGridLayout", {
				CellSize = UDim2.fromScale(0.5, 0.5),
				CellPadding = UDim2.fromScale(0.05, 0.05),
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}, {
				Aspect = e("UIAspectRatioConstraint", {
					AspectRatio = 1,
				}),
			}),
			Children = e(PlacementContext.provider, nil, {
				Assets = e(childAssets, {
					Assets = props.Assets,
				}),
			}),
		}),
	})
end
