const React = require("../../Packages/React")
const PlacementContext = require("./Contexts/PlacementContext")
const Build = require("./Frames/Build")
const ObjectSelect = require("./Frames/ObjectSelect")
const e = React.createElement

return function()
	return e(PlacementContext.provider, {}, {
		Build = e(Build),
		ObjectSelect = e(ObjectSelect),
	})
end
