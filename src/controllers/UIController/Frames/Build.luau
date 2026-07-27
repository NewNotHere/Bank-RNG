const React = require("../../../Packages/React")
const BuildRegion = require("../Classes/BuildRegion")
const TextButton = require("../Classes/TextButton")
const CameraContext = require("../Contexts/CameraContext")
const PlacementContext = require("../Contexts/PlacementContext")
const UIStateContext = require("../Contexts/UIStateContext")
const useSpring = require("../Hooks/useSpring")
local e = React.createElement

return function(props)
	local context = React.useContext(UIStateContext.context)
	local placementContext = React.useContext(PlacementContext.context)
	local cameraContext = React.useContext(CameraContext.context)

	local spring = useSpring(Vector2.new(0.02, 0.45), 7, 0.8)

	React.useEffect(function()
		if context.state == "Build" then
			spring.setTarget(Vector2.new(0.02, 0.45))
		else
			spring.setTarget(Vector2.new(-0.5, 0.45))
		end
	end, { context.state })

	return e(React.Fragment, nil, {
		Frame = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(spring.position.X, spring.position.Y),
			Size = UDim2.fromScale(0.2, 0.7),
		}, {
			Aspect = e("UIAspectRatioConstraint", {
				AspectRatio = 0.6,
			}),

			CloseButton = e(TextButton, {
				Text = "X",
				Size = UDim2.fromScale(0.1, 0.1),

				[React.Event.Activated] = function()
					context.setState("Menu")
					placementContext.revertMode()
					cameraContext.setDefaultCamera()
				end,
			}, {
				Aspect = e("UIAspectRatioConstraint", {
					AspectRatio = 1,
				}),
			}),
			SelectButton = e(TextButton, {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 1),
				Size = UDim2.fromScale(0.7, 0.15),
				BackgroundTransparency = 1,
				Text = "Select",
				TextColor3 = Color3.fromRGB(255, 255, 255),

				[React.Event.Activated] = function()
					context.setState("Select")
					placementContext:setSelectMode()
				end,
			}, {
				Stroke = e("UIStroke", {
					Thickness = 3,
				}),
			}),
			Scrolling = e("ScrollingFrame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 0.7),
				BackgroundTransparency = 1,
			}, {
				UIList = e("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Top,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),
				R1 = e(BuildRegion, {
					Text = "Walls",
					Assets = { "Wall", "ReinforcedWall" },
				}),
				R2 = e(BuildRegion, {
					Text = "Defenses",
					Assets = { "LaserArray" },
				}),
			}),
		}),
	})
end
