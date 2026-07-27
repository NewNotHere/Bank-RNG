local React = require("../../../Packages/React")
local UIStateContext = require("../Contexts/UIStateContext")
local useSpring = require("../Hooks/useSpring")
local e = React.createElement

return function(props)
	return e("Frame", {
		Size = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
	})
end
