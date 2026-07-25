const React = require("../../Packages/React")
const PlacementContext = require("./Contexts/PlacementContext")
const UIStateContext = require("./Contexts/UIStateContext")
const Build = require("./Frames/Build")
const Menu = require("./Frames/Menu")
const Cash = require("./Frames/Cash")
const e = React.createElement

return function()
	return e(UIStateContext.provider, nil, {
		Menu = e(PlacementContext.provider, nil, {
			Menu = e(Menu),
		}),
		CashFrame = e(Cash),
		Build = e(PlacementContext.provider, nil, {
			Build = e(Build),
		}),
	})
end
