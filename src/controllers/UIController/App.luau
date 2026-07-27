const React = require("../../Packages/React")
const IntIndex = require("./Classes/IntIndex")
const CameraContext = require("./Contexts/CameraContext")
const PlacementContext = require("./Contexts/PlacementContext")
const UIStateContext = require("./Contexts/UIStateContext")
const Build = require("./Frames/Build")
const Menu = require("./Frames/Menu")
const Cash = require("./Frames/Cash")
local Select = require("./Frames/Select")
const e = React.createElement

return function()
	return e(UIStateContext.provider, nil, {
		Menu = e(PlacementContext.provider, nil, {
			CamContext = e(CameraContext.provider, nil, {
				Menu = e(Menu),
			}),
		}),
		CashFrame = e(Cash),
		Build = e(PlacementContext.provider, nil, {
			CamContext = e(CameraContext.provider, nil, {
				Build = e(Build),
			}),
		}),
		SelectFrame = e(Select),

		--IntIndex = e(IntIndex),
	})
end
